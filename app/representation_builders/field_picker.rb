class FieldPicker
  def initialize(presenter)
    @presenter = presenter
  end

  def pick
    build_fields
    @presenter
  end

  def fields
    @fields ||= validate_fields
  end

  private

  # 檢查 fields 是不是都包含在該 presenter 的 build_attributes 裡面
  # 1. 如果 presenter 沒有帶 params[:fields]，則直接回傳 pickable
  # 2. 將 params[:fields] split 之後存在 fields 變數
  # 3. 如果 fields 為空則回傳 pickable
  # 4. 對 fields 的每一個值進行 validate，invalid 則 raise error
  # 5. 回傳 fields
  def validate_fields
    return pickable if @presenter.params[:fields].blank?

    fields = @presenter.params[:fields].split(',').collect(&:strip)
    fields.each do |field|
      error!(field) if !pickable.include?(field)
    end

    fields
  end

  def build_fields
    fields.each do |field|
      target = @presenter.respond_to?(field) ? @presenter : @presenter.object
      @presenter.data[field] = target.send(field) if target
    end
  end

  def error!(field)
    build_attributes = @presenter.class.build_attributes.join(',')
    raise RepresentationBuilderError.new("fields=#{field}"),
    "Invalid Field Pick. Allowed field: (#{build_attributes})"
  end

  def pickable
    @pickable ||= @presenter.class.build_attributes
  end
end
