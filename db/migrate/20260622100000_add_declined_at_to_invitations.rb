class AddDeclinedAtToInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :invitations, :declined_at, :datetime
  end
end
