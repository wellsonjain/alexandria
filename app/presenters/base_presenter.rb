class BasePresenter
  # Define Class level instance variable
  # @relations = []
  # @sort_attributes = []
  # @filter_attributes = []
  # @build_attributes = []

  # class << self
  #   attr_accessor :relations, :sort_attributes, :filter_attributes, :build_attributes

  #   def build_with(*args)
  #     @build_attributes = args.map(&:to_s)
  #   end

  #   def related_to(*args)
  #     @relations = args.map(&:to_s)
  #   end

  #   def sort_by(*args)
  #     @sort_attributes = args.map(&:to_s)
  #   end

  #   def filter_by(*args)
  #     @filter_attributes = args.map(&:to_s)
  #   end
  # end

  CLASS_ATTRIBUTES = {
    build_with: :build_attributes,
    sort_by: :sort_attributes,
    filter_by: :filter_attributes,
    related_to: :relations
  }

  CLASS_ATTRIBUTES.each { |key, value| instance_variable_set("@#{value}", []) }

  class << self
    attr_accessor *CLASS_ATTRIBUTES.values

    CLASS_ATTRIBUTES.each do |key, value|
      define_method key do |*args|
        instance_variable_set("@#{value}", args.map(&:to_s))
      end
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
