class ArticlesController < ApplicationController
  before_action :set_articles

  def index
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to articles_path
    else
      render :index
    end
  end

  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path
  end

  private
    def article_params
      params.require(:article).permit(:url)
    end

    def set_articles
      @articles = Article.order(created_at: :desc)
    end
end