class User < ActiveRecord::Base
  include AASM
  default_scope -> {order('id')}

  serialize :messages, Hash

  enum status: [:in_line, :sended, :delivered, :failed]
  validates :url, presence: true
  before_destroy :check_status

  aasm column: :status, whiny_transitions: false, no_direct_assignment: true do
    state :in_line, :initial => true
    state :sended
    state :delivered
    state :failed

    event :message_sended do
      transitions from: :in_line, to: :sended
    end

    event :message_delivered do
      transitions from: :sended, to: :delivered
    end

    event :message_failed do
      transitions from: :in_line, to: :failed
    end
  end


  def increment_message_relation(message)
    unless self.status == User.statuses[:delivered]
      self.message_sended!
      self.message_delivered!
    end

    if self.messages.has_key?(message.id.to_s)
      self.messages[message.id.to_s] += 1
    else
      self.messages[message.id.to_s] = 1
    end
    self.save
  end


  private

  def check_status
    unless self.status.to_sym == :in_line
      errors.add(:base, "You can't destroy user which already sended.")
      false
    end
  end
end
