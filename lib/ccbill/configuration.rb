module CCBill
  class Configuration
    attr_accessor :account
    attr_accessor :subaccount

    attr_accessor :salt
    attr_accessor :default_currency

    attr_accessor :datalink_username
    attr_accessor :datalink_password

    attr_accessor :mode
    attr_accessor :test_endpoint

    def initialize
      @default_currency = "840" # USD
      @subaccount = "0000"
      @mode = :test
    end

    def test?
      mode.to_sym == :test
    end
  end
end