class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true, length: {maximum: Settings.name.max_length}
  validates :email, presence: true,
                    length: {maximum: Settings.email.max_length},
                    format: {with: Regexp.new(Settings.email.valid_email_regex)}
  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
