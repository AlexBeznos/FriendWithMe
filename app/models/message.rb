class Message < ActiveRecord::Base
  include AASM
  serialize :img_urls, Array

  default_scope -> { order(:id) }

  enum status: [:active, :unactive]
  validates :body, presence: true
  before_destroy :is_last_active?

  aasm column: :status, whiny_transitions: false, no_direct_assignment: true do
    state :unactive, :initial => true
    state :active

    event :activate do
      transitions from: :unactive, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :unactive, :guard => :is_any_active?
    end
  end

  def change_status
    if status.to_sym == :active
      self.deactivate!
    elsif status.to_sym == :unactive
      self.activate!
    end
  end

  def retrive_attachments
    unless self.attachment == ''
      self.img_urls = []
      vk = VkontakteApi::Client.new
      vk.photos.getById(photos: attachment.delete('photo'), extended: 0).each do |p|
        self.img_urls << p['src']
      end
      puts self.img_urls
      self.save
    end
  end

  handle_asynchronously :retrive_attachments
  private

    def is_any_active?
      Message.where(status: Message.statuses[:active]).count != 1
    end

    def is_last_active?
      self.status.to_sym != :active
    end

end
