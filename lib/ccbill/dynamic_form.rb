# https://www.ccbill.com/cs/wiki/tiki-index.php?page=Dynamic+Pricing

module CCBill
  class DynamicPricing

    attr_accessor :fields, :flexform_id


    DEFAULTS = {
      # account: config.account ...
      currency_code:  "USD",
      initial_period: 30,
      rebills:        99,
      subaccount:     "0000"
    }

    # CCBill's field names are not rubyish.
    FIELD_MAP = {
      currency_code:    "currencyCode",
      initial_price:    "initialPrice",
      initial_period:   "initialPeriod",
      account:          "clientAccnum",
      subaccount:       "clientSubacc",
      recurring_price:  "recurringPrice",
      recurring_period: "recurringPeriod",
      rebills:          "numRebills"
    }

    ENDPOINT = "https://api.ccbill.com/wap-frontflex/flexforms/"

    def initialize(flexform_id, fields = {})
      self.flexform_id = flexform_id
      self.fields = DEFAULTS.merge(fields)
    end

    def url
    end

    def valid?
      # got all the required fields?
    end

    def digest
      # md5
    end


  end
end