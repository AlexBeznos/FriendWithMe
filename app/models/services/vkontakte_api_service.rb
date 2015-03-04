class VkontakteApiService

  def send_message
    get_user = User.where(status: User.statuses[:in_line]).limit(1).first
    permorm(get_user.id)
  end

  handle_asynchronously :send_message, :run_at => Proc.new { 45.seconds.from_now }

  private

  def perform(id)
    user = User.find(id)
    unless user.nil?
      active_ = retrive_active_record
      unless active_['messages'].empty? && active_['accounts'].empty?
        random_record = retrive_random_records(active_)
        client = vk_client(random_record['account'])
        domain = URI.parse(user.url).path.delete('/')
        url = shorten_url(user, random_record['message'])

        begin
          client.messages.send(domain: domain, message: "#{random_record['message'].body}<br>#{url}", attachment: random_record['message'].attachment)
          user.message_sended!
        rescue VkontakteApi::Error => e
          if e.error_code == 14
            puts '++++++++++'
            puts 'Puts captcha'
            puts e.captcha_img
            puts e.captcha_sid
            puts e.methods
            client = DeathByCaptcha.new(ENV['CAPTCHA_USER'], ENV['CAPTCHA_PASS'], :http)
            captcha = client.decode(url: e.captcha_img)

            client.messages.send(domain: domain,
                                 message: "#{random_record['message'].body}<br>#{url}",
                                 attachment: random_record['message'].attachment,
                                 captcha_sid: e.captcha_sid,
                                 captcha_key: captcha.text)

            user.message_sended!
            vk = VkontakteApiService.new
            vk.send_message
          elsif e.error_code == 5
            random_record['account'].deactivate!
            Rails.logger.debug "Account #{account.email} was deactivated!"
            vk = VkontakteApiService.new
            vk.send_message
          else
            user.message_sended!
            vk = VkontakteApiService.new
            vk.send_message
            raise "VK Api error but not a capcha. Error: #{e.message}"
          end
        end

        vk = VkontakteApiService.new
        vk.send_message
      end
    else
      Rails.logger.debug 'It is no users!'
    end
  end

  def retrive_active_record
    data = {}
    data['messages'] = Message.where('status = ?', Message.statuses[:active])
    data['accounts'] = Account.where('status = ?', Account.statuses[:active])
    data
  end

  def retrive_random_records(hash)
    data = {}
    data['message'] = random(hash['messages'])
    data['account'] = random(hash['accounts'])
    data
  end

  def random(query)
    puts '++++++++'
    puts query
    puts query.count
    puts query.count.class
    rand_id = rand(1..query.count)
    query.take(rand_id).last
  end

  def vk_client(account)
    puts account.inspect
    puts account.access_token
    VkontakteApi::Client.new(account.access_token)
  end

  def shorten_url(user, message)
    site_url = "#{ENV['ROOT_URL']}redirect?account=#{SecureId.new(user.id.to_s).encrypt}&message=#{SecureId.new(message.id.to_s).encrypt}"
    client = Googl.client(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_PASSWORD'])

    url = client.shorten(site_url)
    url.short_url
  end

  def solve_captcha(img_url)
    client = DeathByCaptcha.new(ENV['CAPTCHA_USER'], ENV['CAPTCHA_PASS'], :http)
    captcha = client.decode(url: img_url)
    captcha.text
  end
end
