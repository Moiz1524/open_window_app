require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }

  describe "GET /dashboard" do
    context "when authenticated" do
      before { sign_in user }

      it "renders the dashboard with ok status" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it "displays the welcome message" do
        get dashboard_path
        expect(response.body).to include("Welcome")
      end
    end

    context "when not authenticated" do
      it "redirects to the sign in page" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
