class Account < ActiveRecord::Base

  enum status: [:unactive, :active]

  validates :email, uniqueness: true, presence: true

end
