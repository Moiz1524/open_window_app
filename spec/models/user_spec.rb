require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with an email and password" do
      user = User.new(email: "user@example.com", password: "password123")
      expect(user).to be_valid
    end

    it "is invalid without an email" do
      user = User.new(password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid with a duplicate email" do
      User.create!(email: "user@example.com", password: "password123")
      user = User.new(email: "user@example.com", password: "password456")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid without a password" do
      user = User.new(email: "user@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is invalid with a password shorter than 6 characters" do
      user = User.new(email: "user@example.com", password: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "profile picture" do
    let(:user) { User.create!(email: "user@example.com", password: "password123") }

    it "accepts a valid image" do
      user.profile_picture.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/avatar.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )
      expect(user).to be_valid
    end

    it "rejects an unsupported content type" do
      user.profile_picture.attach(
        io: StringIO.new("hello"),
        filename: "notes.txt",
        content_type: "text/plain"
      )
      expect(user).not_to be_valid
      expect(user.errors[:profile_picture]).to be_present
    end
  end
end
