require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it "is valid with a name" do
      expect(Organization.new(name: "Acme Inc.")).to be_valid
    end

    it "is invalid without a name" do
      organization = Organization.new(name: "")
      expect(organization).not_to be_valid
      expect(organization.errors[:name]).to be_present
    end

    it "is invalid with a duplicate name (case-insensitive)" do
      Organization.create!(name: "Acme Inc.")
      organization = Organization.new(name: "acme inc.")
      expect(organization).not_to be_valid
      expect(organization.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it "exposes its users through memberships" do
      organization = Organization.create!(name: "Acme Inc.")
      user = User.create!(email: "user@example.com", password: "password123")
      Membership.create!(user: user, organization: organization, role: :super_admin)

      expect(organization.users).to include(user)
    end
  end
end
