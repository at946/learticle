class ArticlesController < ApplicationController
  before_action :redirect_unless_logged_in
  before_action :set_articles, only: [:index, :create]
  before_action :set_article, only: [:edit, :update]

  def index
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.uid = current_user["uid"]
    if @article.save
      redirect_to articles_path(type: :reading_later)
    else
      render :index
    end
  end

  def edit
    redirect_to articles_path(type: :reading_later) if @article.uid != current_user["uid"]
  end

  def update
    redirect_to articles_path(type: :reading_later) if @article.uid != current_user["uid"]

    redirect_link_type = :finish_reading
    @article.assign_attributes(finish_reading_params)
    
    # あとで読むリストの記事だった場合
    if @article.finish_reading_at.blank?
      @article.finish_reading_at = Time.now
      redirect_link_type = :reading_later
    end

    if @article.save
      redirect_to articles_path(type: redirect_link_type)
    else
      render :edit
    end
  end

  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path(type: :reading_later)
  end

  private
    def article_params
      params.require(:article).permit(:url)
    end

    def finish_reading_params
      params.require(:article).permit(:memo)
    end

    def set_articles
      case params[:type]
      when "reading_later"
        @articles = Article.where(uid: current_user["uid"], finish_reading_at: nil).order(:created_at)
      when "finish_reading"
        @articles = Article.where(uid: current_user["uid"]).where.not(finish_reading_at: nil).order(finish_reading_at: :desc)
      else
        redirect_to articles_path(type: :reading_later)
      end
    end

    def set_article
      begin
        @article = Article.find(params[:id])
      rescue => exception
        redirect_to articles_path(type: :reading_later)
      end
    end
end