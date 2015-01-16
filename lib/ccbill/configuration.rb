module CCBill
  class Configuration
    attr_accessor :account
    attr_accessor :subaccount

    attr_accessor :salt
    attr_accessor :default_currency


    def initialize
      @default_currency = "USD"
      @subaccount = "0000"
    end
  end
end