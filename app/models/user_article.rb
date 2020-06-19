class UserArticle < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :article_id,
    uniqueness: { scope: [:user_id] }

  validates :memo,
    length: { maximum: 1000 }
end
