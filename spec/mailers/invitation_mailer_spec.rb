require "rails_helper"

RSpec.describe InvitationMailer, type: :mailer do
  let(:organization) { Organization.create!(name: "Acme Inc.") }
  let(:inviter) { User.create!(email: "admin@example.com", password: "password123") }
  let(:invitation) do
    organization.invitations.create!(email: "invitee@example.com", invited_by: inviter)
  end

  describe "#invite" do
    subject(:mail) { described_class.invite(invitation) }

    it "is addressed to the invitee" do
      expect(mail.to).to eq([ "invitee@example.com" ])
    end

    it "names the organization in the subject" do
      expect(mail.subject).to include("Acme Inc.")
    end

    it "embeds the unique invitation link" do
      expect(mail.body.encoded).to include("/invitations/#{invitation.token}/accept")
    end
  end
end
