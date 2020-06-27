class ArticlesController < ApplicationController
  before_action :redirect_unless_logged_in
  before_action :set_articles, only: [:index, :create]
  before_action :set_user_article, only: [:edit, :update]

  def index
    @article = Article.new
  end

  def create
    @article = Article.find_by(url: article_params[:url])
    @article ||= Article.new(article_params)

    if @article.save
      user_article = UserArticle.new
      user_article.user = current_user
      user_article.article = @article

      if user_article.save
        redirect_to articles_path(type: :reading_later)
      else
        @article.errors.add(:base, :already_registered, message: "この記事はすでに登録されています")
        render :index
      end

    else
      render :index
    end
  end

  def edit
  end

  def update
    redirect_link_type = :finish_reading
    pixela_flag = false
    @user_article.assign_attributes(user_article_params)
    
    # あとで読むリストの記事だった場合
    if @user_article.finish_reading_at.blank?
      @user_article.finish_reading_at = Time.now
      redirect_link_type = :reading_later
      pixela_flag = true
    end

    if @user_article.save
      if pixela_flag && !Rails.env.test?
        res = Faraday.put("#{ENV['PIXELA_BASE_URL']}/graphs/#{current_user.id}/increment") do |req|
          req.headers["X-USER-TOKEN"] = ENV["PIXELA_X_USER_TOKEN"]
          req.headers["Content-Length"] = 0
        end
        unless res.success?
          puts "Faraday failed when finish reading."
          puts "status: #{res.status}"
          puts "headers: #{res.headers}"
          puts "body: #{res.body}"
        end
      end
      redirect_to articles_path(type: redirect_link_type)
    else
      render :edit
    end
  end

  def destroy
    user_article = UserArticle.find_by(id: params[:id], user_id: current_user.id)
    unless user_article.nil?
      article = user_article.article
      user_article.destroy
      article.destroy if article.user_articles.blank?
    end
    redirect_to articles_path(type: :reading_later)
  end

  private
    def article_params
      params.require(:article).permit(:url)
    end

    def user_article_params
      params.require(:user_article).permit(:memo)
    end

    def set_articles
      case params[:type]
      when "reading_later"
        @user_articles = current_user.user_articles.where(finish_reading_at: nil).order(created_at: :asc)
      when "finish_reading"
        @user_articles = current_user.user_articles.where.not(finish_reading_at: nil).order(finish_reading_at: :desc)
      else
        redirect_to articles_path(type: :reading_later)
      end
    end

    def set_user_article
      @user_article = UserArticle.find_by(id: params[:id], user_id: current_user.id)
      redirect_to articles_path(type: :reading_latter) if @user_article.nil?
      @article = @user_article.article unless @user_article.nil?
    end
end