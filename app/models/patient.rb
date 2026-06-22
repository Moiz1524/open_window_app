class Patient < ApplicationRecord
  encrypts :email, :name, :phone_no, :dob, :gender, :address  
end
