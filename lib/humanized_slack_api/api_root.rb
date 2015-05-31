module HumanizedSlackApi
  class ApiRoot
    attr_reader :channels, :users
    def initialize(token)
      @slack = Slack::Client.new(token: token)
      @channels = Channels.new(@slack.channels_list, self)
      @users = Users.new(@slack.users_list, self)
    end
  end
end
