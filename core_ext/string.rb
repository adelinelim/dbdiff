class String
  def to_data
    JSON.parse(self)
  end

  def color(code)
    "\e[38;5;#{code}m#{self}\e[0m"
  end

  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end
