class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 after_create :generate_token
 acts_as_messageable
 
  def is_confirmed?
    self.confirmed_at.nil? ? false : true
  end

  private
    def generate_token
      secret = Digest::SHA1.hexdigest(SecureRandom.urlsafe_base64)
      self.token = User.find_by(token: secret.to_s) ? generate_token : secret
      self.save
    end
end
