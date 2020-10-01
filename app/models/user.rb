class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  validates :name, presence: true, 
    length: {maximum: Settings.user.name.max_length}

  validates :email, presence: true,
    length: {maximum: Settings.user.email.max_length},
    format: {with: Settings.user.email.regex},
    uniqueness: true


  validates :password, presence: true, 
    length: {minimum: Settings.user.password.min_length}

  has_secure_password

  before_save :downcase_email
  before_create :create_activation_digest
  def User.digest string
    cost = if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create string, cost: cost
  end
  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end
  
  def forgets
    update_attribute :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
    self.email.downcase!
  end

  def create_activation_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
end
