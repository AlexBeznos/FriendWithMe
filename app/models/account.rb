class Account < ActiveRecord::Base
  include AASM

  default_scope -> { order(:id) }
  enum status: [:unactive, :active]
  validates :email, uniqueness: true, presence: true
  after_update :check_for_account_status

  aasm column: :status, whiny_transitions: false, no_direct_assignment: true do
    state :unactive, :initial => true
    state :active

    event :activate do
      transitions from: :unactive, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :unactive
      before do
        self.access_token = nil
      end
    end
  end

  private
  def check_for_account_status
    if access_token == nil
      self.deactivate! unless status.to_sym == :unactive
    else
      self.activate! unless status.to_sym == :active
    end
  end
end
