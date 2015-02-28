require 'rails_helper'

RSpec.describe "accounts/new", :type => :view do
  before(:each) do
    assign(:account, Account.new(
      :email => "MyString",
      :status => 1,
      :uid => "MyString",
      :access_token => "MyString"
    ))
  end

  it "renders new account form" do
    render

    assert_select "form[action=?][method=?]", accounts_path, "post" do

      assert_select "input#account_email[name=?]", "account[email]"

      assert_select "input#account_status[name=?]", "account[status]"

      assert_select "input#account_uid[name=?]", "account[uid]"

      assert_select "input#account_access_token[name=?]", "account[access_token]"
    end
  end
end
