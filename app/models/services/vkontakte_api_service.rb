class VkontakteApiService

  def send_message
    if configatron.aproved
      get_user = User.where(status: User.statuses[:in_line]).limit(1).first
      perform(get_user.id)
    end
  end

  private

  def perform(id)
    user = User.find(id)
    unless user.nil?
      active_ = retrive_active_record
      random_record = retrive_random_records(active_)
      client = VkontakteApi::Client.new(random_record['account'].access_token)
      domain = URI.parse(user.url).path.delete('/')
      url = random_record['message'].url
      unless active_['messages'].empty? && active_['accounts'].empty?
        begin
          client.messages.send(domain: domain, message: "#{random_record['message'].body}<br>#{url}", attachment: random_record['message'].attachment)
          user.message_sended!
        rescue VkontakteApi::Error => e
          if e.error_code == 14
            Rails.logger.info "Captcha exseption: img: #{e.captcha_img}, id: #{e.captcha_sid}, method: #{e.methods} "

            client_captcha = DeathByCaptcha.new(ENV['CAPTCHA_USER'], ENV['CAPTCHA_PASS'], :http)
            captcha = client_captcha.decode(url: e.captcha_img)

            client.messages.send(domain: domain,
                                 message: "#{random_record['message'].body}<br>#{url}",
                                 attachment: random_record['message'].attachment,
                                 captcha_sid: e.captcha_sid,
                                 captcha_key: captcha.text)

            user.message_sended!
          elsif e.error_code == 5
            Rails.logger.info "Bad authorization, account #{random_record['account'].id} #{random_record['account'].email}"

            random_record['account'].deactivate!
            user.message_failed!
          elsif e.error_code == 7
            Rails.logger.info "No persissions for this action. user #{user.url}"

            user.message_failed!
          elsif e.error_code == 6
            Rails.logger.info "Toooo many requests per second!"

            user.message_failed!
          else
            Rails.logger.info "Something undetected wierd happend!"

            user.message_failed!
          end
        end
      end
    else
      raise 'It is no users!'
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
    rand_id = rand(1..query.count)
    query.take(rand_id).last
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
