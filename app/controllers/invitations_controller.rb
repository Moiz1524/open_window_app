class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def new
    @invitation = @organization.invitations.new
  end

  def create
    email = invitation_params[:email].to_s.strip.downcase
    @invitation = @organization.invitations.new(email: email, invited_by: current_user)

    if @organization.users.exists?(email: email)
      flash.now[:alert] = "This user is already added in #{@organization.name}."
      render :new, status: :unprocessable_content
    elsif @organization.invitations.pending.exists?(email: email)
      flash.now[:alert] = "This user is already invited."
      render :new, status: :unprocessable_content
    elsif @invitation.save
      InvitationMailer.invite(@invitation).deliver_later
      redirect_to dashboard_path, notice: "Invitation sent to #{email}."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # An invitation is always sent into the organization the current user is a
  # Super Admin of. Members (no super_admin membership) can't invite.
  def set_organization
    @organization = current_user.memberships.super_admin.first&.organization
    return if @organization

    redirect_to dashboard_path, alert: "Only super admins can invite teammates."
  end

  def invitation_params
    params.require(:invitation).permit(:email)
  end
end
