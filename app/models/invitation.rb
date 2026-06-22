class Invitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User"

  # Generates a unique, URL-safe token used in the invitation link.
  has_secure_token :token

  # Role the invitee will be granted on acceptance. Always :member for now;
  # kept here so a Super Admin can pick a role at invite time in the future.
  enum :role, { member: 0, super_admin: 1 }

  scope :pending, -> { where(accepted_at: nil, declined_at: nil) }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def pending?
    accepted_at.nil? && declined_at.nil?
  end

  def declined?
    declined_at.present?
  end
end
