module HasName
  def name=(value)
    super(value ? value.titleize: value)
  end
end