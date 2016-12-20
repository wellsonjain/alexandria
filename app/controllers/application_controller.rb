class ApplicationController < ActionController::API

  rescue_from QueryBuilderError, with: :builder_error
  rescue_from RepresentationBuilderError, with: :builder_error

  protected

  def builder_error(error)
    render status: 400, json: {
      error: {
        type: error.class,
        message: error.message,
        invalid_params: error.invalid_params
      }
    }
  end

  def filter(scope)
    Filter.new(scope, params.to_unsafe_hash).filter
  end

  def sort(scope)
    Sorter.new(scope, params).sort
  end

  def paginate(scope)
    paginator = Paginator.new(scope, request.query_parameters, current_url)
    response.headers['Link'] = paginator.links
    paginator.paginate
  end

  def current_url
    request.base_url + request.path
  end
end
