class Hash
  def to_pj
    JSON.pretty_generate(self)
  end

  def to_hpj
    "<pre>" + to_pj + "</pre>"
  end

  def to_str
    to_pj
  end

  def to_s
    to_pj
  end

  def +(other)
    to_str + other.to_str
  end
end
