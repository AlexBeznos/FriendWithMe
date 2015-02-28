json.array!(@accounts) do |account|
  json.extract! account, :id, :email, :status, :uid, :access_token
  json.url account_url(account, format: :json)
end
