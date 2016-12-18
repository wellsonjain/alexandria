class BasePresenter
  # Define Class level instance variable
  @build_attributes = []

  class << self
    attr_accessor :build_attributes

    def build_with(*args)
      @build_attributes = args.map(&:to_s)
    end
  end

  attr_accessor :object, :params, :data

  def initialize(object, params, options={})
    @object = object
    @params = params
    @options = options
    @data = HashWithIndifferentAccess.new
  end

  # 在呼叫 to_json 的時候就會先呼叫 as_json 來 create data structure
  def as_json(*)
    @data
  end
end
