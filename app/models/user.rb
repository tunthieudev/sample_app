class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  scope :sorted_by_created_at, ->{order(created_at: :asc)}

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: Settings.name.max_length}
  validates :email, presence: true,
                    length: {maximum: Settings.email.max_length},
                    format: {with: Regexp.new(Settings.email.valid_email_regex)}
  validates :password, presence: true,
                       length: {minimum: Settings.password.min_length},
                       allow_nil: true

  has_secure_password

  def password_reset_expired?
    reset_sent_at < Settings.digit_2.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Activates an account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Returns the hash digest of the given string.
  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost => cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  private

  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
