class InvitationAcceptancesController < ApplicationController
  before_action :load_invitation

  def show
  end

  def create
    @user = User.new(email: @invitation.email, password: user_params[:password],
      password_confirmation: user_params[:password_confirmation])

    if @user.save
      @invitation.update!(accepted_at: Time.current)
      Membership.create!(user: @user, organization: @invitation.organization, role: @invitation.role)
      sign_in(@user)
      redirect_to dashboard_path, notice: "Welcome to #{@invitation.organization.name}!"
    else
      render :show, status: :unprocessable_content
    end
  end

  def decline
    @invitation.update!(declined_at: Time.current)
    redirect_to root_path, notice: "You have declined the invitation."
  end

  private

  def load_invitation
    @invitation = Invitation.pending.find_by(token: params[:token])

    unless @invitation
      redirect_to root_path, alert: "This invitation link is invalid or has already been used."
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
