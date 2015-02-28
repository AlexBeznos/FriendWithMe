module ApplicationHelper

  def add_status(status)
    if status == Account.statuses[:active]
      "success"
    elsif status == Account.statuses[:unauthorized]
      "warning"
    else
      "error"
    end
  end
end
