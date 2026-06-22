require "rails_helper"

RSpec.describe Membership, type: :model do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:organization) { Organization.create!(name: "Acme Inc.") }

  describe "validations" do
    it "is valid with a user, organization, and role" do
      membership = Membership.new(user: user, organization: organization, role: :super_admin)
      expect(membership).to be_valid
    end

    it "is invalid without a user" do
      expect(Membership.new(organization: organization, role: :member)).not_to be_valid
    end

    it "is invalid without an organization" do
      expect(Membership.new(user: user, role: :member)).not_to be_valid
    end

    it "does not allow the same user to join the same organization twice" do
      Membership.create!(user: user, organization: organization, role: :super_admin)
      duplicate = Membership.new(user: user, organization: organization, role: :member)
      expect(duplicate).not_to be_valid
    end
  end

  describe "roles" do
    it "defaults to member" do
      membership = Membership.create!(user: user, organization: organization)
      expect(membership.role).to eq("member")
    end

    it "supports the super_admin role" do
      membership = Membership.create!(user: user, organization: organization, role: :super_admin)
      expect(membership).to be_super_admin
    end
  end
end
