require "ccbill/version"
require "ccbill/dynamic_form"
require "helpers/configuration"

module CCBill
  extend Configuration

  define_setting :account_number
  define_setting :subaccount_number
  define_setting :salt

  define_setting :default_currency, "USD"
end
