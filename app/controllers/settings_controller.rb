class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    if current_user.update(settings_params)
      redirect_to settings_path, notice: "Profile picture updated."
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      # Discard the rejected (and possibly non-image) in-memory attachment so the
      # page re-renders the previously persisted state instead of a broken blob.
      current_user.reload
      render :show, status: :unprocessable_entity
    end
  end

  def destroy_profile_picture
    current_user.profile_picture.purge_later
    redirect_to settings_path, notice: "Profile picture removed."
  end

  private

  def settings_params
    params.require(:user).permit(:profile_picture)
  end
end
