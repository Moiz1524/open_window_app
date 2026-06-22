require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "renders the sign up form" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end

    it "includes the organization name field" do
      get new_user_registration_path
      expect(response.body).to include("user[organization_name]")
    end
  end

  describe "POST /users" do
    context "with valid params" do
      let(:valid_params) do
        {
          user: {
            organization_name: "Acme Inc.",
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "creates a new organization" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(Organization, :count).by(1)
        expect(Organization.last.name).to eq("Acme Inc.")
      end

      it "makes the signing-up user the super admin of the organization" do
        post user_registration_path, params: valid_params

        membership = User.last.memberships.first
        expect(membership.organization).to eq(Organization.last)
        expect(membership.role).to eq("super_admin")
      end

      it "redirects to the dashboard" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "without an organization name" do
      let(:params_without_org) do
        {
          user: {
            organization_name: "",
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "does not create a user" do
        expect {
          post user_registration_path, params: params_without_org
        }.not_to change(User, :count)
      end

      it "does not create an organization" do
        expect {
          post user_registration_path, params: params_without_org
        }.not_to change(Organization, :count)
      end

      it "re-renders the sign up form with unprocessable entity status" do
        post user_registration_path, params: params_without_org
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a duplicate organization name" do
      before { Organization.create!(name: "Acme Inc.") }

      let(:duplicate_org_params) do
        {
          user: {
            organization_name: "acme inc.",
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "does not create a user" do
        expect {
          post user_registration_path, params: duplicate_org_params
        }.not_to change(User, :count)
      end

      it "re-renders the sign up form with unprocessable entity status" do
        post user_registration_path, params: duplicate_org_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with invalid user params" do
      let(:invalid_params) do
        {
          user: {
            organization_name: "Acme Inc.",
            email: "",
            password: "short",
            password_confirmation: "mismatch"
          }
        }
      end

      it "does not create a user" do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "does not create an organization" do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(Organization, :count)
      end

      it "re-renders the sign up form with unprocessable entity status" do
        post user_registration_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
