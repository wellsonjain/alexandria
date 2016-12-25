class BasePresenter
  # * Instance variable 會把帶進來的參數 `(object, params, data)` set
  #    data 會為 `HashWithIndifferentAccess`
  # * `#as_json` 把 data serialize 成 JSON
  # * `.build_with` 定義哪些欄位是被允許用來 build representation，
  #    並且將其存在 class variable `build_attributes` (array)

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

  def build(actions)
    actions.each{ |action| send(action) }
    self
  end

  def fields
    FieldPicker.new(self).pick
  end

  def embeds
    EmbedPicker.new(self).embed
  end
end
