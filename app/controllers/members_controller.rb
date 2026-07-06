class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @members = @organization.memberships.includes(:user).order(created_at: :asc)
    @pending_invitations = @organization.invitations.pending.includes(:invited_by).order(created_at: :desc)
  end

  private

  def set_organization
    @organization = current_user.organizations.first
    redirect_to dashboard_path, alert: "Organization not found." unless @organization
  end
end
