require 'forwardable'

module HumanizedSlackApi
  class Channels
    attr_reader :channel
    extend Forwardable
    include Enumerable
    def_delegators(:@channels, :each)

    def initialize(channels_list, root_parent)
      @channels_list = channels_list
      @channels = @channels_list['channels'].map {|c| Channel.build(c, root_parent) }

      @channels.map(&:name).each do |channel_name|
        define_singleton_method(channel_name) do
          @channels.find {|c| c.name == __method__.to_s }
        end
      end
    end

    def find_by(ops)
      methods = Channel.new.methods
      target_keys = ops.keys.select {|k| methods.include?(k) }
      @channels.select do |channel|
        target_keys.map { |m| channel.send(m) == ops[m] }.all?
      end
    end
  end

  class Channel
    attr_reader :id, :name, :created, :creator, :is_archived, :is_general, :is_member, :num_members, :topic, :purpose, :last_read, :latest, :unread_count, :unread_count_display

    def self.build(json, root_parent)
      channel = Channel.new
      channel.instance_eval do
        @root_parent = root_parent
        @id = json['id']
        @name = json['name']
        @created = json['created']
        @creator = json['creator']
        @is_archived = json['is_archived']
        @is_general = json['is_general']
        @members = json['members']
        @is_member = json['is_member']
        @num_members = json['num_members']
        @topic = Topic.build(json['topic'])
        @purpose = Purpose.build(json['purpose'])
        @last_read = json['last_read']
        @latest = json['latest']
        @unread_count = json['unread_count']
        @unread_count_display = json['unread_count_display']
      end
      channel
    end

    def members
      @members.first.class == User ? @members : @members = @members.map {|m| @root_parent.users.find_by(id: m).first }
    end

    class ChannelAttr
      attr_reader :value, :creator, :last_set

      def self.build(json)
        attrs = self.new
        attrs.instance_eval do
          @value = json['value']
          @creator = json['creator']
          @last_set = json['last_set']
        end
        attrs
      end
    end

    class Topic < ChannelAttr; end
    class Purpose < ChannelAttr; end
  end
end
