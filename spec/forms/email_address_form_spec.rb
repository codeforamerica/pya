require "rails_helper"

RSpec.describe EmailAddressForm do
  describe "before validation" do
    it "strips the whitespace from the email" do
      form = EmailAddressForm.new(email_address: "test@example.com ")
      form.valid?

      expect(form.email_address).to eq "test@example.com"
    end
  end

  describe "#valid?" do
    context "when the email address is valid" do
      it "returns true" do
        form = EmailAddressForm.new(email_address: "test@example.com")

        expect(form.valid?).to be true
      end
    end

    context "when the email address is invalid" do
      it "returns false for an improperly formatted email" do
        form = EmailAddressForm.new(email_address: "invalid-email")

        expect(form.valid?).to be false
        expect(form.errors[:email_address]).to include("Please enter a valid email address.")
      end

      it "returns false when the email is blank" do
        form = EmailAddressForm.new(email_address: "")

        expect(form.valid?).to be false
        expect(form.errors[:email_address]).to include("Please enter a valid email address.")
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      form = EmailAddressForm.new(email_address: "test@example.com")

      expect(form.email_address).to eq("test@example.com")
    end
  end

  describe "DNS resolution (security regression)" do
    # The valid_email2 gem is capable of MX/A record lookups (valid_mx?,
    # valid_strict_mx?, disposable?), which would let a submitted email
    # domain trigger outbound DNS queries from the server to an
    # attacker-controlled nameserver. EmailAddressForm must only use the
    # gem's format-only check (ValidEmail2::Address#valid?). Do not add
    # MX or disposable-domain checks without a security review.
    before do
      allow(Resolv::DNS).to receive(:open)
                              .and_raise("EmailAddressForm must not perform DNS lookups on submitted email domains")
      allow(Resolv::DNS).to receive(:new)
                              .and_raise("EmailAddressForm must not perform DNS lookups on submitted email domains")
    end

    it "does not resolve DNS for a well-formed email on an attacker-controlled domain" do
      form = described_class.new(email_address: "probe@attacker-controlled.example")

      expect { form.valid? }.not_to raise_error
      expect(form).to be_valid
    end

    it "does not resolve DNS for a malformed email" do
      form = described_class.new(email_address: "not-an-email@@bad..domain")

      expect { form.valid? }.not_to raise_error
      expect(form).not_to be_valid
    end
  end
end
