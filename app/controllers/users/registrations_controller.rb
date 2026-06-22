module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: :create

    # Signing up always creates a brand-new organization. The signing-up user
    # becomes its creator and Super Admin. User, organization, and membership
    # are created together in a single transaction.
    def create
      build_resource(sign_up_params.except(:organization_name))
      resource.organization_name = sign_up_params[:organization_name]
      @organization = Organization.new(name: resource.organization_name)

      if valid_signup?
        persist_signup!
        sign_up_succeeded
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :organization_name ])
    end

    private

    # Validate the user and the organization up front so both sets of errors
    # surface together on the form, before we write anything to the database.
    def valid_signup?
      user_valid = resource.valid?
      org_valid = @organization.valid?

      @organization.errors[:name].each do |message|
        resource.errors.add(:organization_name, message)
      end

      user_valid && org_valid
    end

    def persist_signup!
      ActiveRecord::Base.transaction do
        @organization.save!
        resource.save!
        Membership.create!(user: resource, organization: @organization, role: :super_admin)
      end
    end

    def sign_up_succeeded
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    end
  end
end
