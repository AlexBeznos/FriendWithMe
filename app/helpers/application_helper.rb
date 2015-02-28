module ApplicationHelper

  def add_status(status)
    st = status.try(:to_sym)
    if st == :active
      "success"
    elsif st == :unactive
      "warning"
    else
      "danger"
    end
  end
end
