class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :invitations, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
