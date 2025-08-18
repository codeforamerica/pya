module StateNames
  extend ActiveSupport::Concern

  STATE_NAMES = {
    "AZ" => "Arizona",
    "ID" => "Idaho",
    "MD" => "Maryland",
    "NJ" => "New Jersey",
    "NY" => "New York",
    "NC" => "North Carolina"
  }.freeze

  def state_full_name(code)
    STATE_NAMES[code&.upcase]
  end
end
