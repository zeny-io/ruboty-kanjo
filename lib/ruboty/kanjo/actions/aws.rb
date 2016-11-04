require 'aws-sdk'

module Ruboty::Kanjo::Actions
  class AWS < Ruboty::Actions::Base
    ONE_HOUR = 60 * 60 * 6

    INSTANCE_TYPES = %w(
      t1.micro t2.nano t2.micro t2.small t2.medium t2.large
      m1.small m1.medium m1.large m1.xlarge
      m3.medium m3.large m3.xlarge m3.2xlarge
      m4.large m4.xlarge m4.2xlarge m4.4xlarge m4.10xlarge m4.16xlarge
      m2.xlarge m2.2xlarge m2.4xlarge
      cr1.8xlarge
      r3.large r3.xlarge r3.2xlarge r3.4xlarge r3.8xlarge
      x1.16xlarge x1.32xlarge
      i2.xlarge i2.2xlarge i2.4xlarge i2.8xlarge
      hi1.4xlarge
      hs1.8xlarge
      c1.medium c1.xlarge
      c3.large c3.xlarge c3.2xlarge c3.4xlarge c3.8xlarge
      c4.large c4.xlarge c4.2xlarge c4.4xlarge c4.8xlarge
      cc1.4xlarge cc2.8xlarge
      g2.2xlarge g2.8xlarge
      cg1.4xlarge
      p2.xlarge p2.8xlarge p2.16xlarge
      d2.xlarge d2.2xlarge d2.4xlarge d2.8xlarge
    )

    def billing
      services = list_services

      prices = {}
      prices['Total'] = get_price

      services.each do |service|
        prices[service] = get_price(service)
      end

      message.reply(table(prices), code: true)
    end

    def spot_instance
      az = message[:availability_zone]
      types = message[:instances].split(/\s*,\s*/)

      types = types.keep_if { |type| INSTANCE_TYPES.include?(type) }

      if types.empty?
        message.reply('Not available instance types')
        return
      end

      unless availability_zones.include?(az)
        message.reply('Availability zone is invalid')
        return
      end

      res = ec2.describe_spot_price_history({
        dry_run: false,
        start_time: Time.now,
        end_time: Time.now,
        instance_types: types,
        availability_zone: az,
        max_results: 5,
      })

      prices = {}
      res.spot_price_history.sort_by(&:instance_type).each do |history|
        prices[history.instance_type + ' '+ history.product_description] = "#{history.spot_price} USD"
      end

      message.reply(table(prices), code: true)
    end

    def list_services
      resp = cloudwatch.list_metrics(
        namespace: 'AWS/Billing',
        metric_name: 'EstimatedCharges',
        dimensions: [
          { name: 'Currency', value: 'USD' }
        ]
      )

      services = []
      resp.metrics.each do |metric|
        metric.dimensions.each do |dimension|
          services.push(dimension.value) if dimension.name == 'ServiceName'
        end
      end

      services
    end

    def get_price(service = nil)
      now = Time.now

      dimensions = [
        { name: 'Currency', value: 'USD' }
      ]

      dimensions.push(name: 'ServiceName', value: service) if service

      resp = cloudwatch.get_metric_statistics(
        namespace: 'AWS/Billing',
        metric_name: 'EstimatedCharges',
        dimensions: dimensions,
        start_time: now - ONE_HOUR,
        end_time: now,
        statistics: ['Maximum'],
        period: 60,
        unit: 'None'
      )

      resp.datapoints.last&.maximum
    end

    private

    def cloudwatch
      @cloudwatch ||= Aws::CloudWatch::Client.new(region: 'us-east-1')
    end

    def ec2
      @ec2 ||= Aws::EC2::Client.new()
    end

    def availability_zones
      ec2.describe_availability_zones.availability_zones.map(&:zone_name)
    end

    def table(data)
      col = data.keys.map(&:size).max

      lines = []
      data.each_pair do |key, val|
        lines.push("#{key.ljust(col)} : #{val}")
      end

      lines.join("\n")
    end
  end
end
