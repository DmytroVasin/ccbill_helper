require "ccbill/version"
require "ccbill/configuration"
require "ccbill/dynamic_pricing_form"
require "ccbill/datalink"

module CCBill
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
