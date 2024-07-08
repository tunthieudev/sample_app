class User < ApplicationRecord
  before_save :downcase_email
  validates :name, presence: true, length: {maximum: Settings.default.maximum_name_length}
  validates :email, presence: true, length: {maximum: Settings.default.maximum_email_length},
                    format: {with: Settings.default.valid_email_regex}
  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
