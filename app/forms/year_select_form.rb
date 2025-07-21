class YearSelectForm < Form
  attr_accessor :year

  validates :year, presence: true
  validates :year, inclusion: { in: %w[2023 2024] }, if: -> { year.present? }
end
