require 'ruboty/kanjo'
require 'ruboty/kanjo/actions/aws'

module Ruboty::Handlers
  class Kanjo < Ruboty::Handlers::Base
    on /kanjo aws billing\z/,
      name: :aws_billing, description: 'fetch aws billing'
    on /kanjo aws spot (?<availability_zone>[a-z0-9-]+) (?<instances>[a-z0-9.]+(?:\s*,\s*[a-z0-9.]+)*)\z/,
      name: :aws_spot_instance, description: 'fetch aws spot instacne prices'

    def aws_billing(message)
      Ruboty::Kanjo::Actions::AWS.new(message).billing
    end

    def aws_spot_instance(message)
      Ruboty::Kanjo::Actions::AWS.new(message).spot_instance
    end
  end
end
