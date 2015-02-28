require 'rails_helper'

RSpec.describe "accounts/edit", :type => :view do
  before(:each) do
    @account = assign(:account, Account.create!(
      :email => "MyString",
      :status => 1,
      :uid => "MyString",
      :access_token => "MyString"
    ))
  end

  it "renders the edit account form" do
    render

    assert_select "form[action=?][method=?]", account_path(@account), "post" do

      assert_select "input#account_email[name=?]", "account[email]"

      assert_select "input#account_status[name=?]", "account[status]"

      assert_select "input#account_uid[name=?]", "account[uid]"

      assert_select "input#account_access_token[name=?]", "account[access_token]"
    end
  end
end
