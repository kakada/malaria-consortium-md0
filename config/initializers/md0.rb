class String
  def match_start regex
    return nil unless (self=~regex) == 0
    $1
  end
end