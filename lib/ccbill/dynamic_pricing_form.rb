# https://www.ccbill.com/cs/wiki/tiki-index.php?page=Dynamic+Pricing

module CCBill
  class DynamicPricingError < StandardError; end

  class DynamicPricingForm

    attr_accessor :fields, :flexform_id
    attr_reader :errors

    ENDPOINT = "https://api.ccbill.com/wap-frontflex/flexforms/"

    def initialize(flexform_id, fields)
      self.flexform_id = flexform_id
      self.fields = {
          account:        CCBill.configuration.account,
          subaccount:     CCBill.configuration.subaccount || "0000",
          currency_code:  "USD"
        }.merge(fields)
      @errors = []
    end

    def url
      raise MissingFieldsError.new(errors.join(' ')) if !valid?

      mapped_fields = fields.map do |key, value|
        [ccbill_field(key), value]
      end.to_h.merge("formDigest" => digest)

      ENDPOINT + "#{flexform_id}?" + URI.encode_www_form(mapped_fields)
    end

    def valid?
      @errors = []

      required_fields.each do |reqd|
        if !fields[reqd]
          @errors << "#{reqd} is required."
        end
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
        :account,
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


  end
end