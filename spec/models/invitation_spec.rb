require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:organization) { Organization.create!(name: "Acme Inc.") }
  let(:inviter) { User.create!(email: "admin@example.com", password: "password123") }

  def build_invitation(attrs = {})
    organization.invitations.new({ email: "invitee@example.com", invited_by: inviter }.merge(attrs))
  end

  describe "validations" do
    it "is valid with an email, organization, and inviter" do
      expect(build_invitation).to be_valid
    end

    it "is invalid without an email" do
      invitation = build_invitation(email: "")
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to be_present
    end

    it "is invalid with a malformed email" do
      expect(build_invitation(email: "not-an-email")).not_to be_valid
    end

    it "requires an organization and an inviter" do
      expect(Invitation.new(email: "invitee@example.com")).not_to be_valid
    end
  end

  describe "token" do
    it "generates a unique token on create" do
      invitation = build_invitation
      invitation.save!
      expect(invitation.token).to be_present
    end
  end

  describe "role" do
    it "defaults to member" do
      expect(build_invitation.tap(&:save!).role).to eq("member")
    end
  end

  describe ".pending" do
    it "includes invitations with no accepted_at or declined_at" do
      pending = build_invitation.tap(&:save!)
      accepted = build_invitation(email: "accepted@example.com").tap { |i| i.save!; i.update!(accepted_at: Time.current) }
      declined = build_invitation(email: "declined@example.com").tap { |i| i.save!; i.update!(declined_at: Time.current) }

      scope = Organization.find(organization.id).invitations.pending
      expect(scope).to include(pending)
      expect(scope).not_to include(accepted)
      expect(scope).not_to include(declined)
    end
  end

  describe "#pending?" do
    it "is true when neither accepted nor declined" do
      expect(build_invitation.tap(&:save!)).to be_pending
    end

    it "is false when accepted" do
      inv = build_invitation.tap { |i| i.save!; i.update!(accepted_at: Time.current) }
      expect(inv).not_to be_pending
    end

    it "is false when declined" do
      inv = build_invitation.tap { |i| i.save!; i.update!(declined_at: Time.current) }
      expect(inv).not_to be_pending
    end
  end

  describe "#declined?" do
    it "is true when declined_at is set" do
      inv = build_invitation.tap { |i| i.save!; i.update!(declined_at: Time.current) }
      expect(inv).to be_declined
    end
  end
end
