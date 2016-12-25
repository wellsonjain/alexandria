class BooksController < ApplicationController
  def index
    # books = orchestrate_query(Book.all).map do |book|
    #   BookPresenter.new(book, params).fields.embeds
    # end
    books = orchestrate_query(Book.all)
    serializer = Alexandria::Serializer.new(data: books, params: params, actions: [:fields, :embeds])

    render json: serializer.to_json
  end
end
