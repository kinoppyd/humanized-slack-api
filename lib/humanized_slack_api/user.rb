module HumanizedSlackApi
  class Users
    def initialize(users_list, root_parent)
      @users_list = users_list
      @users = @users_list['members'].map {|u| User.build(u, root_parent) }

      @users.map(&:name).each do |user_name|
        define_singleton_method(user_name) do
          @users.find {|c| c.name == __method__.to_s }
        end
      end
    end

    def fetch(id)
      @users.find {|u| u.id.to_s == id.to_s } || raise
    end

    def find_by(ops)
      methods = User.new.methods
      target_keys = ops.keys.select {|k| methods.include?(k) }
      @users.select do |user|
        target_keys.map { |m| user.send(m) == ops[m] }.all?
      end
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
