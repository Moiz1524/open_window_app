class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  has_one_attached :profile_picture do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 200, 200 ]
    attachable.variant :nav, resize_to_fill: [ 64, 64 ]
  end

  ACCEPTED_PROFILE_PICTURE_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  MAX_PROFILE_PICTURE_SIZE = 5.megabytes

  validate :acceptable_profile_picture

  # Virtual attribute: only used by the sign-up form to name the organization
  # the user is creating. Invited users (joining an existing org) never set it.
  attr_accessor :organization_name

  private

  def acceptable_profile_picture
    return unless profile_picture.attached?

    unless profile_picture.blob.content_type.in?(ACCEPTED_PROFILE_PICTURE_TYPES)
      errors.add(:profile_picture, "must be a PNG, JPEG, WEBP, or GIF image")
    end

    if profile_picture.blob.byte_size > MAX_PROFILE_PICTURE_SIZE
      errors.add(:profile_picture, "must be smaller than 5 MB")
    end
  end
end
