# frozen_string_literal: true
<<<<<<< HEAD

=======
>>>>>>> main
module EventLogger
  module_function

  def log(event)
    Rails.logger.info(
      category: "pya_event",
      event: event.to_s.strip,
      timestamp: Time.now.utc.iso8601
    )
  end
end
