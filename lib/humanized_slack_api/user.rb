require 'forwardable'

module HumanizedSlackApi
  class Users
    extend Forwardable
    include Enumerable
    def_delegators(:@users, :each)

    def initialize(users_list, root_parent)
      @users = []
      @users_names = {}
      @users_ids = {}
      users_list['members'].each do |u|
        user = User.build(u, root_parent)
        @users << user
        @users_names[user.name.to_s] = user
        @users_ids[user.id.to_s] = user
      end

    end

    def find(key)
      key = key.id if key.instance_of?(User)
      @users_ids[key.to_s] || @users_names[key.to_s] || raise(NoUserFoundError.new("Not found [#{key}]"))
    end

    class NoUserFoundError < StandardError; end
  end

  class User
    attr_reader :id, :name, :deleted, :color, :profile, :is_admin, :is_owner, :is_primary_owner, :is_restricted, :is_ultra_restricted, :has_2fa, :has_files

    def self.build(json, root_parent)
      user = User.new
      user.instance_eval do
        @root_parent = root_parent
        @id = json['id']
        @name = json['name']
        @deleted = json['deleted']
        @color = json['color']
        @profile = Profile.build(json['profile'])
        @is_admin = json['is_admin']
        @is_owner = json['is_owner']
        @is_primary_owner = json['is_primary_owner']
        @is_restricted = json['is_restricted']
        @is_ultra_restricted = json['is_ultra_restricted']
        @has_2fa = json['has_2fa']
        @has_files = json['has_files']
      end
      user
    end

    def belongs_channels
      @channels ||= find_belongs_channels
    end

    def find_belongs_channels
      @root_parent.channels.select { |channel|
        channel.members.include?(self)
      }
    end

    class Profile
      attr_reader :first_name, :last_name, :real_name, :email, :skype, :phone, :image_24, :image_32, :image48, :image72, :image192

      def self.build(json)
        profile = self.new
        profile.instance_eval do
          @first_name = json['first_name']
          @last_name = json['last_name']
          @real_name = json['real_name']
          @email = json['email']
          @skype = json['skype']
          @phone = json['phone']
          @image_24 = json['image_24']
          @image_32 = json['image_32']
          @image48 = json['image48']
          @image72 = json['image72']
          @image192 = json['image192']
        end
        profile
      end
    end
  end
end
