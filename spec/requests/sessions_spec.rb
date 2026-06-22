require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }

  describe "GET /users/sign_in" do
    it "renders the sign in form" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users/sign_in" do
    context "with valid credentials" do
      it "signs in and redirects to the dashboard" do
        post user_session_path, params: { user: { email: user.email, password: "password123" } }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid credentials" do
      it "re-renders the sign in form with unprocessable entity status" do
        post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /users/sign_out" do
    before { sign_in user }

    it "signs out the user and redirects" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
