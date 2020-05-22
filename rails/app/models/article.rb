class Article < ApplicationRecord
  validates :url,
    presence: true,
    format: /\A#{URI::regexp(%w(http https))}\z/,
    length: { maximum: 2000 }
end
