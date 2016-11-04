require 'ruboty/kanjo'
require 'ruboty/kanjo/actions/aws'

module Ruboty::Handlers
  class Kanjo < Ruboty::Handlers::Base
    on /kanjo aws\z/, name: :aws, description: 'fetch aws billing'

    def aws(message)
      Ruboty::Kanjo::Actions::AWS.new(message).call
    end
  end
end
