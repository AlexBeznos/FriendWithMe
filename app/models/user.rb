class User < ActiveRecord::Base
  include AASM

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


  def send_message
    if self
      active_messages = Message.where(status: Message.statuses[:active])
      active_accounts = Account.where(status: Account.statuses[:active])

      if !active_messages.empty? && !active_accounts.empty?
        account = random(active_accounts)
        message = random(active_messages)
        client = vk_client(account)
        domain = URI.parse(self.url).path.delete('/')
        url = shorten_url(self, message)

        begin
          if client.messages.send(domain: domain, message: "#{message.body}<br>#{url}", attachment: message.attachment)
            self.message_sended!
          end
        rescue => e
          Rails.logger.info ['send_message', e]
        end

        send_next_message
      end
    end
  end

  def increment(message)
    self.message_delivered! unless self.status.to_sym == :delivered
    self.messages[message.id.to_s] +=1
    self.save
  end

  handle_asynchronously :send_message, :run_at => Proc.new { 30.seconds.from_now }
  handle_asynchronously :increment

  private
  def random(query)
    begin
      rand_id = rand(1..query.count)
      query.take(rand_id).last
    rescue => e
      Rails.logger.info ['random', e]
    end
  end

  def vk_client(account)
    begin
      VkontakteApi::Client.new(account.access_token)
    rescue => e
      Rails.logger.info ['vk_client', e]
    end
  end

  def shorten_url(user, message)
    begin
      site_url = "#{ENV['ROOT_URL']}redirect?account=#{SecureId.new(user.id.to_s).encrypt}&message=#{SecureId.new(message.id.to_s).encrypt}"
      client = Googl.client(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_PASSWORD'])

      url = client.shorten(site_url)
      url.short_url
    rescue => e
      Rails.logger.info ['Shorten url', e]
    end
  end

  def send_next_message
    users = User.where(status: User.statuses[:in_line])
    unless users.empty?
      users.first.send_message
    else
      raise 'It is no users to deliver more'
    end
  end

  def check_status
    unless self.status.to_sym == :in_line
      errors.add(:base, "You can't destroy user which already sended.")
      false
    end
  end

  handle_asynchronously :send_next_message, :run_at => Proc.new { 30.seconds.from_now }

end
