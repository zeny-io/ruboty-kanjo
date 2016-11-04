require 'aws-sdk'

module Ruboty::Kanjo::Actions
  class AWS < Ruboty::Actions::Base
    ONE_HOUR = 60 * 60

    def call
      services = list_services

      col = (services + ['Total']).map(&:size).max

      total_price = get_price
      msg = ["#{'Total'.ljust(col)} : #{total_price} USD"]

      services.each do |service|
        msg.push("#{service.ljust(col)} : #{get_price(service)} USD")
      end

      message.reply(msg.join("\n"))
    end

    def list_services
      resp = cloudwatch.list_metrics(namespace: 'AWS/Billing',
                                     metric_name: 'EstimatedCharges',
                                     dimensions: [
                                       { name: 'Currency', value: 'USD' }
                                     ])

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

      resp.datapoints.last.maximum
    end

    private

    def cloudwatch
      @cloudwatch ||= Aws::CloudWatch::Client.new(region: 'us-east-1')
    end
  end
end
