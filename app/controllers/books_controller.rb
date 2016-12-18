class BooksController < ApplicationController
  def index
    books = sort(paginate(Book.all)).map do |book|
      FieldPicker.new(BookPresenter.new(book, params)).pick
    end

    render json: { data: books }
  end
end
