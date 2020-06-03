class Article < ApplicationRecord
  before_validation :strip_all_space_from_url
  before_save :set_ogp_info

  validates :url,
    format: { with: /\A#{URI::regexp(%w(http https))}\z/, message: "に https:// または http:// から始まる文字列を入力してください" },
    length: { maximum: 2000 }

  validates :memo,
    length: { maximum: 1000 }

  private
    def strip_all_space_from_url
      self.url.gsub!(/(^[[:space:]]+)|([[:space:]]+$)/, '')
    end

    def set_ogp_info
      begin
        res = Faraday.get(self.url)
        doc = Nokogiri::HTML.parse(res.body)
      rescue
        self.errors.add(:url, "のページは存在しないようです")
        throw :abort
      end

      # title
      if (title = doc.xpath("//meta[@property='og:title']/@content").to_s).present?
        self.title = title
      elsif (title = doc.xpath("//meta[@name='title']/@content").to_s).present?
        self.title = title
      elsif (title = doc.title).present?
        self.title = title
      else
        self.title = self.url
      end

      # image_url
      if (image_url = doc.xpath("//meta[@property='og:image']/@content").first.to_s).present?
        self.image_url = image_url 
      end
    end
end
