class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [
      Settings.image.max_width,
      Settings.image.max_height
    ]
  end

  validates :content, presence: true,
                      length: {maximum: Settings.micropost.content.max_length}
  validates :image, content_type: {
                      in: %w(image/jpeg image/gif image/png),
                      message: "must be a valid image format"
                    },
                    size: {
                      less_than: Settings.digit_5.megabytes,
                      message: "should be less than 5MB"
                    }

  # default_scope -> {order created_at: :desc}
  scope :newest, ->{order(created_at: :desc)}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
end
