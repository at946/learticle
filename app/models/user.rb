class User < ApplicationRecord
  # Associations
  has_many :user_articles, dependent: :destroy
  has_many :articles, through: :user_articles

  # モデル作成時にidにランダムな文字列をセットする
  before_create :set_id

  # 作成日時降順でレコードを取得する
  default_scope -> { order(created_at: :desc) }

  validates :auth0_uid,
    presence: true,
    uniqueness: true

  private
    def set_id
      while self.id.blank? || User.find_by(id: self.id).present? do
        self.id = SecureRandom.alphanumeric(20)
      end
    end
end
