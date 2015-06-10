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

      @users.each do |user|
        [user.name, user.id].each do |method_key|
          define_singleton_method(method_key) do
            key = __method__.to_s
            @users_ids[key] || @users_names[key] || raise
          end
        end
      end
    end

    def find(id)
      @users_ids[id.to_s] || raise
    end
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
