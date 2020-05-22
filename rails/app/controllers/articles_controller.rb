class ArticlesController < ApplicationController
  def index
    @articles = Article.all.order(created_at: :desc)
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to root_path
    else
      render :index
    end
  end

  private
    def article_params
      params.require(:article).permit(:url)
    end
end