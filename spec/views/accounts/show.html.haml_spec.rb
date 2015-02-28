require 'rails_helper'

RSpec.describe "accounts/show", :type => :view do
  before(:each) do
    @account = assign(:account, Account.create!(
      :email => "Email",
      :status => 1,
      :uid => "Uid",
      :access_token => "Access Token"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Uid/)
    expect(rendered).to match(/Access Token/)
  end
end
