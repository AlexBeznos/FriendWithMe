require 'rufus-scheduler'

s = Rufus::Scheduler.singleton
job = s.every '1m' do
  VkontakteApiService.new.send_message
end

s.every '10m' do
  Rails.logger.info "Scheduler is #{job.running? ? 'runing' : 'not runing, do smth'}!"
  Rails.logger.info "And messages is #{configatron.aproved ? 'sends' : 'not sends'}"
end
