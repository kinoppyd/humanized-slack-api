module HumanizedSlackApi
  class ApiRoot
    attr_reader :channels, :users
    def initialize(token)
      @slack = Slack::Client.new(token: token)
      raise(AuthenticationError.new("Api auth faild for token '#{ApiRoot.mask_token(token)}'")) unless @slack.auth_test['ok']
      @channels = Channels.new(@slack.channels_list, self)
      @users = Users.new(@slack.users_list, self)
    end

    def self.mask_token(token)
      token_chunks = token.split('-')
      last_chunk = token_chunks.pop
      token_chunks.map { |chunk| 'X' * chunk.size }.push(last_chunk).join('-')
    end
  end

  class AuthenticationError < StandardError; end
end
