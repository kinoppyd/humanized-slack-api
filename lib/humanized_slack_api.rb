require 'slack'

require "humanized_slack_api/api_root"
require "humanized_slack_api/channel"
require "humanized_slack_api/user"
require "humanized_slack_api/version"

module HumanizedSlackApi
  def self.api_root(token)
    HumanizedSlackApi::ApiRoot.new(token)
  end
end
