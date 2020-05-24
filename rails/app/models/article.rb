class Article < ApplicationRecord
  validates :url,
    # presence: true,
    format: { with: /\A#{URI::regexp(%w(http https))}\z/, message: "に https:// または http:// から始まる文字列を入力してください" },
    length: { maximum: 2000 }
end
