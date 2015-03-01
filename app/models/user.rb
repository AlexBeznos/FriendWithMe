class User < ActiveRecord::Base
  include AASM

  serialize :messages, Hash

  enum status: [:in_line, :sended, :delivered]
  validates :url, presence: true

  aasm column: :status, whiny_transitions: false, no_direct_assignment: true do
    state :in_line, :initial => true
    state :sended
    state :delivered

    event :send do
      transitions from: :in_line, to: :sended
    end

    event :deliver do
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
        url = shorten_url(account, message)

        client.messages.send( domain: domain,
                              message: "#{message}<br>#{url}",
                              attachments: message.attachment)
        user.send!
        send_next_message
      end
    end
  end

  def increment(message)
    self.deliver! unless self.status.to_sym ==:delivered
    self.message[message.id.to_s] =+ 1
    self.save
  end

  handle_asynchronously :send_message, :run_at => Proc.new { 30.seconds.from_now }
  handle_asynchronously :increment

  private
  def random(query)
    rand_id = rand(1..query.count)
    query.take(rand_id).last
  end

  def vk_client(account)
    VkontakteApi::Client.new(account.access_token)
  end

  def shorten_url(account, message)
    site_url = "http://friendwith.me/redirect?account=#{SecureId.new(account.id).encrypt}&message=#{SecureId.new(message.id).encrypt}"
    client = Googl.client(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_PASSWORD'])

    url = client.shorten(site_url)
    url.short_url
  end

  def send_next_message
    User.where(status: User.statuses[:in_line]).first.send_message
  end
end
