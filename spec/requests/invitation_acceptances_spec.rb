require "rails_helper"

RSpec.describe "InvitationAcceptances", type: :request do
  let(:organization) { Organization.create!(name: "Acme Inc.") }
  let(:inviter) do
    User.create!(email: "admin@example.com", password: "password123").tap do |u|
      Membership.create!(user: u, organization: organization, role: :super_admin)
    end
  end
  let!(:invitation) do
    organization.invitations.create!(email: "invitee@example.com", invited_by: inviter)
  end

  describe "GET /invitations/:token/accept" do
    it "renders the account setup form for a valid token" do
      get accept_invitation_path(token: invitation.token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Join #{organization.name}")
      expect(response.body).to include(invitation.email)
    end

    it "redirects to root for an invalid token" do
      get accept_invitation_path(token: "bogus")
      expect(response).to redirect_to(root_path)
    end

    it "redirects to root when the invitation has already been accepted" do
      invitation.update!(accepted_at: Time.current)
      get accept_invitation_path(token: invitation.token)
      expect(response).to redirect_to(root_path)
    end

    it "redirects to root when the invitation has been declined" do
      invitation.update!(declined_at: Time.current)
      get accept_invitation_path(token: invitation.token)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /invitations/:token/accept" do
    let(:valid_params) do
      { user: { password: "password123", password_confirmation: "password123" } }
    end

    context "with a valid token and matching passwords" do
      it "creates a new user with the invitation email" do
        expect {
          post accept_invitation_path(token: invitation.token), params: valid_params
        }.to change(User, :count).by(1)
        expect(User.last.email).to eq("invitee@example.com")
      end

      it "creates a membership for the new user" do
        post accept_invitation_path(token: invitation.token), params: valid_params
        membership = User.last.memberships.first
        expect(membership.organization).to eq(organization)
        expect(membership.role).to eq("member")
      end

      it "marks the invitation as accepted" do
        post accept_invitation_path(token: invitation.token), params: valid_params
        expect(invitation.reload.accepted_at).to be_present
      end

      it "signs in the new user and redirects to the dashboard" do
        post accept_invitation_path(token: invitation.token), params: valid_params
        expect(response).to redirect_to(dashboard_path)
      end

      it "expires the link so it cannot be used again" do
        post accept_invitation_path(token: invitation.token), params: valid_params
        post accept_invitation_path(token: invitation.token), params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "with mismatched passwords" do
      let(:bad_params) do
        { user: { password: "password123", password_confirmation: "different" } }
      end

      it "does not create a user and re-renders the form" do
        expect {
          post accept_invitation_path(token: invitation.token), params: bad_params
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not mark the invitation as accepted" do
        post accept_invitation_path(token: invitation.token), params: bad_params
        expect(invitation.reload.accepted_at).to be_nil
      end
    end
  end

  describe "POST /invitations/:token/decline" do
    it "marks the invitation as declined" do
      post decline_invitation_path(token: invitation.token)
      expect(invitation.reload.declined_at).to be_present
      expect(invitation.reload.accepted_at).to be_nil
    end

    it "does not create a user" do
      expect {
        post decline_invitation_path(token: invitation.token)
      }.not_to change(User, :count)
    end

    it "redirects to the root path" do
      post decline_invitation_path(token: invitation.token)
      expect(response).to redirect_to(root_path)
    end

    it "expires the link so it cannot be used after declining" do
      post decline_invitation_path(token: invitation.token)
      get accept_invitation_path(token: invitation.token)
      expect(response).to redirect_to(root_path)
    end
  end
end
