class SecureId
  attr_reader :id
  KEY = ENV["SECURE_KEY"]

  def initialize(id)
    @id = id
  end

  def encrypt
    Base64.urlsafe_encode64(aes(id)).gsub /\s/, ''
  end

  def decrypt
    aes_decrypt(Base64.urlsafe_decode64(id))
  end

  def aes(id)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(KEY)
    cipher.iv = initialization_vector = cipher.random_iv
    cipher_text = cipher.update(id)
    cipher_text << cipher.final
    return initialization_vector + cipher_text
  end

  def aes_decrypt(encrypted)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = Digest::SHA256.digest(KEY)
    cipher.iv = encrypted.slice!(0,16)
    d = cipher.update(encrypted)
    d << cipher.final
  end
end
