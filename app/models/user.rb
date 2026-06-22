class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  # Virtual attribute: only used by the sign-up form to name the organization
  # the user is creating. Invited users (joining an existing org) never set it.
  attr_accessor :organization_name
end
