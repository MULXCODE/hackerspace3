class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :lockable, :timeoutable,
         :omniauthable

  has_many :assignments, dependent: :destroy

  validates :preferred_img, inclusion: { in: VALID_IMAGE_OPTIONS }

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by_email(data['email'])

    user ||= User.new(full_name: data['name'],
                      email: data['email'],
                      password: Devise.friendly_token[0, 20])
    user.skip_confirmation_notification!
    user.save
    user.update(google_img: data['image'])
    user
  end

  def admin_privileges?
    return true unless (assignments.pluck(:title) & COMP_ADMIN).empty?
  end

  def make_site_admin
    Competition.current.assignments.find_or_create_by(user: self, title: ADMIN)
  end

  def event_assignment
    assignment = Competition.current.assignments.find_by(user: self, title: VIP)
    return assignment unless assignment.nil?
    Competition.current.assignments.find_or_create_by(user: self, title: PARTICIPANT)
  end

  def attendances
    event_assignment.attendances
  end

  def preferred_img_url
    case preferred_img
    when GRAVITAR
      gravitar_img_url
    when GOVHACK
      govhack_img
    when GOOGLE
      google_img
    end
  end

  def gravitar_img_url
    GRAVITAR_IMG_REQUEST_URL + Digest::MD5.hexdigest(email)
  end
end
