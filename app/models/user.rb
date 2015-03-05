class User < ActiveRecord::Base
  include AASM
  default_scope -> {order('id')}

  serialize :messages, Hash

  enum status: [:in_line, :sended, :delivered]
  validates :url, presence: true
  before_destroy :check_status

  aasm column: :status, whiny_transitions: false, no_direct_assignment: true do
    state :in_line, :initial => true
    state :sended
    state :delivered

    event :message_sended do
      transitions from: :in_line, to: :sended
    end

    event :message_delivered do
      transitions from: :sended, to: :delivered
    end
  end


  def increment_message_relation(message)
    self.message_sended! if self.status == User.statuses[:in_line]
    self.message_delivered! if self.status == User.statuses[:sended]
    if self.messages.has_key?(message.id.to_s)
      self.messages[message.id.to_s] += 1
    else
      self.messages[message.id.to_s] = 1
    end
    self.save
  end

  handle_asynchronously :increment_message_relation

  private

  def check_status
    unless self.status.to_sym == :in_line
      errors.add(:base, "You can't destroy user which already sended.")
      false
    end
  end
end
