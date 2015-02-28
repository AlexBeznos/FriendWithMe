class Account < ActiveRecord::Base

  enum status: [:unauthorized, :active]

  validates :email, uniqueness: true, presence: true

end
