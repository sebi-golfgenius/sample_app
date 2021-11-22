class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  # create active relationship. This gives an array of users that self is following. The self
  # is automatically assigned as the follower_id of the relationship.
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  # create passive relationship. This gives an array of users that are following us. It is an array
  # of followers. The followed_id is automatically set to self.id
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password

  # returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remembers a user in the db for use in the persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # sends the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_send_at: Time.zone.now)
  end

  # Send password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # returns true if the password reset has expired
  def password_reset_expired?
    reset_send_at < 2.hours.ago
  end

  # Defines a proto-feed
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id) # following_ids - provided by ActiveRecord. Returns a list with all ids of followed users

    # other option
    # part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    # Micropost.joins(user: :followers).where(part_of_feed, { id: id })
  end

  # Follow a user
  def follow(other_user)
    following << other_user # appends at the end of the following array
  end

  # Unfollow a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true is the current user is following other user
  def following?(other_user)
    following.include?(other_user)
  end

  private

    def downcase_email
      self.email.downcase!
    end
end
