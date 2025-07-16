class PhoneParser
  def self.normalize(raw_phone_number)
    valid, phony_normalized = self.phony_normalize_or_error(raw_phone_number)
    valid ? self.e164(phony_normalized) : raw_phone_number&.to_s
  end

  private

  def self.phony_normalize_or_error(raw_phone_number)
    return [false, nil] if raw_phone_number.nil?
    return [false, ""] if raw_phone_number == ""

    raw_phone_number = raw_phone_number.to_s

    phony_normalized = Phony.normalize(raw_phone_number, cc: '1')
    if Phony.plausible?(phony_normalized)
      [true, phony_normalized]
    else
      [false, raw_phone_number]
    end
  end

  def self.e164(phony_normalized)
    # Phony normalization results in a phone number with no punctuation and with a country calling code.
    "+#{phony_normalized}"
  end
end
