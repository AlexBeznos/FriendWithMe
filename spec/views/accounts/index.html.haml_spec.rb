require 'rails_helper'

RSpec.describe "accounts/index", :type => :view do
  before(:each) do
    assign(:accounts, [
      Account.create!(
        :email => "Email",
        :status => 1,
        :uid => "Uid",
        :access_token => "Access Token"
      ),
      Account.create!(
        :email => "Email",
        :status => 1,
        :uid => "Uid",
        :access_token => "Access Token"
      )
    ])
  end

  it "renders a list of accounts" do
    render
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Uid".to_s, :count => 2
    assert_select "tr>td", :text => "Access Token".to_s, :count => 2
  end
end
