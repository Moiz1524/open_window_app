require "rails_helper"

RSpec.describe "Invitations", type: :request do
  let(:organization) { Organization.create!(name: "Acme Inc.") }

  let(:super_admin) do
    User.create!(email: "admin@example.com", password: "password123").tap do |user|
      Membership.create!(user: user, organization: organization, role: :super_admin)
    end
  end

  let(:member) do
    User.create!(email: "member@example.com", password: "password123").tap do |user|
      Membership.create!(user: user, organization: organization, role: :member)
    end
  end

  describe "GET /invitations/new" do
    it "redirects guests to sign in" do
      get new_invitation_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the form for a super admin" do
      sign_in super_admin
      get new_invitation_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Invite a teammate")
    end

    it "redirects a member to the dashboard" do
      sign_in member
      get new_invitation_path
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "POST /invitations" do
    before { sign_in super_admin }

    context "with a new email" do
      let(:params) { { invitation: { email: "invitee@example.com" } } }

      it "creates a pending invitation in the organization" do
        expect {
          post invitations_path, params: params
        }.to change(organization.invitations, :count).by(1)

        invitation = organization.invitations.last
        expect(invitation.email).to eq("invitee@example.com")
        expect(invitation.invited_by).to eq(super_admin)
        expect(invitation.token).to be_present
        expect(invitation).to be_pending
      end

      it "sends the invitation email" do
        expect {
          post invitations_path, params: params
        }.to have_enqueued_mail(InvitationMailer, :invite)
      end

      it "redirects to the dashboard with a notice" do
        post invitations_path, params: params
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:notice]).to include("invitee@example.com")
      end

      it "normalizes the email to lowercase" do
        post invitations_path, params: { invitation: { email: "INVITEE@Example.com" } }
        expect(organization.invitations.last.email).to eq("invitee@example.com")
      end
    end

    context "when the email already belongs to a member of the org" do
      before { member }

      it "does not create an invitation and shows an 'already added' message" do
        expect {
          post invitations_path, params: { invitation: { email: member.email } }
        }.not_to change(Invitation, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("already added in #{organization.name}")
      end
    end

    context "when a pending invitation already exists for the email" do
      before do
        organization.invitations.create!(email: "invitee@example.com", invited_by: super_admin)
      end

      it "does not create a duplicate and shows an 'already invited' message" do
        expect {
          post invitations_path, params: { invitation: { email: "invitee@example.com" } }
        }.not_to change(Invitation, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("already invited")
      end
    end

    context "with an invalid email" do
      it "does not create an invitation and re-renders the form" do
        expect {
          post invitations_path, params: { invitation: { email: "nope" } }
        }.not_to change(Invitation, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
