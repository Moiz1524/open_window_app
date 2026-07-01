require "rails_helper"

RSpec.describe "Settings", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }

  def avatar
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")
  end

  describe "GET /settings" do
    context "when authenticated" do
      before { sign_in user }

      it "renders the settings page" do
        get settings_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Profile picture")
      end
    end

    context "when not authenticated" do
      it "redirects to the sign in page" do
        get settings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /settings" do
    before { sign_in user }

    it "uploads a profile picture" do
      patch settings_path, params: { user: { profile_picture: avatar } }

      expect(response).to redirect_to(settings_path)
      expect(user.reload.profile_picture).to be_attached
    end

    it "rejects a non-image file" do
      text_file = Rack::Test::UploadedFile.new(
        StringIO.new("not an image"), "text/plain", original_filename: "notes.txt"
      )

      patch settings_path, params: { user: { profile_picture: text_file } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.profile_picture).not_to be_attached
    end
  end

  describe "DELETE /settings/profile_picture" do
    before do
      sign_in user
      user.profile_picture.attach(avatar)
    end

    it "removes the profile picture" do
      delete settings_profile_picture_path

      expect(response).to redirect_to(settings_path)
      expect(user.reload.profile_picture).not_to be_attached
    end
  end
end
