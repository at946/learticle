module MetaTagsHelper
  def default_meta_tags
    {
      site: "Learticle",
      # title: "Learticle",
      reverse: true,
      charset: "utf-8",
      description: "LearticleはWebサーフィンを学びの時間に変えるブックマークサービスです。スキマ時間に出会った記事をさくっとリストに登録して、あとで読んだらメモをつけて学びとして管理して、その学びをSNSでアウトプットすることで学びの定着や新たな気づきを得ることができます。",
      canonical: request.original_url,
      og: {
        site_name: :site,
        title: :full_title,
        description: :description,
        type: "website",
        url: :canonical,
        image: image_url("ogp.png"),
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        creator: "@at_946"
      }
    }
  end
end