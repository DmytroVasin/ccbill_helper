# https://www.ccbill.com/cs/wiki/tiki-index.php?page=Dynamic+Pricing

module CCBill
  class DynamicPricingError < StandardError; end

  class DynamicPricingForm

    attr_accessor :fields, :flexform_id
    attr_reader :errors

    # You gotta be logged in to the CCBill admin to be able to see your forms in the sandbox.
    TEST_ENDPOINT = "https://sandbox-api.ccbill.com/wap-frontflex/flexforms/"
    LIVE_ENDPOINT = "https://api.ccbill.com/wap-frontflex/flexforms/"


    def initialize(flexform_id, fields)
      self.flexform_id = flexform_id
      self.fields = {
          subaccount:     CCBill.configuration.subaccount || "0000",
          currency_code:  "USD"
        }.merge(fields)
      @errors = []
    end

    def url
      raise DynamicPricingError.new(errors.join(' ')) if !valid?

      mapped_fields = fields.map do |key, value|
        [ccbill_field(key), value]
      end

      mapped_fields = Hash[mapped_fields].merge("formDigest" => digest)

      endpoint + "#{flexform_id}?" + URI.encode_www_form(mapped_fields)
    end

    def valid?
      @errors = []

      required_fields.each do |reqd|
        @errors << "#{reqd} is required." if !fields[reqd]
      end

      @errors.empty?
    end

    private

    def digest
      hashed_fields = if recurring?
        [
          fields[:initial_price],
          fields[:initial_period],
          fields[:recurring_price],
          fields[:recurring_period],
          fields[:rebills],
          fields[:currency_code],
          CCBill.configuration.salt
        ]
      else
        [
          fields[:initial_price],
          fields[:initial_period],
          fields[:currency_code],
          CCBill.configuration.salt
        ]
      end

      Digest::MD5.hexdigest(hashed_fields.join)
    end

    def recurring?
      # If you're gonna include one recurring field, you should include 'em all.
      fields[:recurring_price] || fields[:recurring_period] || fields[:rebills]
    end

    def required_fields
      req = [
        :subaccount,
        :initial_price,
        :initial_period,
        :currency_code
      ]

      if recurring?
        req += [
          :recurring_price,
          :recurring_period,
          :rebills
        ]
      end

      req
    end

    def ccbill_field(internal)
      # CCBill's field names are not rubyish.
      {
        currency_code:    "currencyCode",
        initial_price:    "initialPrice",
        initial_period:   "initialPeriod",
        account:          "clientAccnum",
        subaccount:       "clientSubacc",
        recurring_price:  "recurringPrice",
        recurring_period: "recurringPeriod",
        rebills:          "numRebills",
        form_digest:      "formDigest"
      }[internal]
    end

    def endpoint
      CCBill.configuration.test? ? TEST_ENDPOINT : LIVE_ENDPOINT
    end


  end
end