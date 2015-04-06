require 'rufus-scheduler'

s = Rufus::Scheduler.singleton
job = s.every '1m' do
  VkontakteApiService.new.send_message
end
