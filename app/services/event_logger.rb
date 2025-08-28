module EventLogger
  module_function

  EVENT_NAME_TO_ID = {
    "issued email challenge"           => 0,
    "correct email challenge"               => 1,
    "incorrect email challenge"             => 2,
    "issued text challenge"            => 3,
    "correct text challenge"           => 4,
    "incorrect text challenge"         => 5,
    "issued ssn challenge"             => 6,
    "correct ssn challenge"            => 7,
    "incorrect ssn challenge"          => 8,
    "client lockout begin"             => 9,
    "issued mailing address challenge" => 10,
    "correct mailing address"          => 11,
    "incorrect mailing address"        => 12,
    "issued pdf download link"         => 13,
    "client pdf download click"        => 14,
    "pdf download link expired"        => 15,
    "unauthorized ssn attempt"         => 16,
    "unauthorized mailing attempt"     => 17
  }.freeze

  def log(event_name, archived_intake_id)
    event_id = EVENT_NAME_TO_ID[event_name]

    Rails.logger.info(
      category: "pya_event",
      event_id: event_id,
      event: event_name,
      state_file_archived_intake_id: archived_intake_id,
      timestamp: Time.now.utc.iso8601
    )
  end
end
