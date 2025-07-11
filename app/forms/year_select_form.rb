class YearSelectForm < Form
  attr_accessor :year

  validates :year, presence: true
end
