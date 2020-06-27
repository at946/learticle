class User < ApplicationRecord
  # Associations
  has_many :user_articles, dependent: :destroy
  has_many :articles, through: :user_articles

  before_create :set_id
  before_create :create_pixela, unless: Proc.new { Rails.env.test? }

  # 作成日時降順でレコードを取得する
  default_scope -> { order(created_at: :desc) }

  validates :auth0_uid,
    presence: true,
    uniqueness: true

  private
    # idにランダムな文字列をセットする
    def set_id
      while self.id.blank? || User.find_by(id: self.id).present? do
        self.id = SecureRandom.alphanumeric(16).downcase
      end
    end

    def create_pixela
      puts "Faraday Start."
      res = Faraday.post("#{ENV['PIXELA_BASE_URL']}/graphs") do |req|
        req.headers["X-USER-TOKEN"] = ENV["PIXELA_X_USER_TOKEN"]
        req.body = {
          id: self.id,
          name: self.id,
          unit: "read",
          type: "int",
          color: "shibafu",
          timezone: "Asia/Tokyo"
        }.to_json
      end
      unless res.success?
        puts "Faraday failed."
        puts "status: #{res.status}"
        puts "headers: #{res.headers}"
        puts "body: #{res.body}"
        throw :abort
      end
      puts "Faraday End."
    end
end
