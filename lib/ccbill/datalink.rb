require 'pry'

module CCBill
  class DataLinkError < StandardError; end

  class DataLink

    # This is just straight from the docs.
    FIELD_LIST_DEFAULTS = {
      new:  [
              :transaction_type,
              :client_sub_account,
              :subscription_id,
              :transaction_timestamp,
              :first_name,
              :last_name,
              :username,
              :password,
              :address,
              :city,
              :state,
              :postal_code,
              :country,
              :email_address,
              :partner_id,
              :subscription_status,
              :accounting_amount,
              :initial_period,
              :recurring_account_amount,
              :recurring_period,
              :recurring_status,
              :card_type,
              :billing_terms_type,
              :billing_contract_id
            ],
      expire: [
        :transaction_type,
        :client_sub_account,
        :subscription_id,
        :expire_date,
        :cancel_date,
        :batched_transaction
      ]
      # TODO: the other txn types
    }


    # REQUEST
      # https://datalink.ccbill.com/data/main.cgi
      # startTime, endTime
        # YYYYMMDDHHIISS (24-hour)
        # max duration 24 hours
      # transactionTypes - inclusion list
      # testMode

      # config:
        # clientAccnum
        # clientSubacc (opt)
        # username, password
        # column ordering
        


    # RESPONSE
      # csv, quoted
      # The order of the params is settable in the admin,
      # but there is a default. Have to make that configurable here, too.
      # Errors start with "Error:"

    attr_writer :test
 
    def initialize(test = true)
      @test = test
    end

    def test?
      @test
    end

    def transactions(start_time, end_time, txn_types)
      params = build_params(start_time, end_time, txn_types)
      response = connection.get "/data/main.cgi", params
      parse_response(response.body)
    end

    private

    def connection
      @connection ||= Faraday.new(url: "https://datalink.ccbill.com/") do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger   # log requests to STDOUT TODO
        faraday.adapter  CCBill.configuration.http_adapter
      end
    end

    def build_params(start_time, end_time, txn_types)
      {
        startTime:        formatted_time(start_time),
        endTime:          formatted_time(end_time),
        transactionTypes: txn_types.join(","),
        username:         CCBill.configuration.datalink.username,
        password:         CCBill.configuration.datalink.password,
        testMode:         test? ? "1" : "0"
        # TODO: account numbers
      }
    end

    def parse_response(raw_response)
      raise DataLinkError.new(raw_response) if raw_response.include?("Error:")
      
      results = []
      CSV.parse(raw_response) do |row|

        transaction = {}
        txn_type = find_txn_type(row)

        fields(txn_type).each_with_index do |field, index|
          transaction[field] = row[index]
        end

        results << transaction
      end

      results
    end

    def find_txn_type(txn)
      FIELD_LIST_DEFAULTS.keys.each do |txn_type|
        return txn_type if txn.include?(txn_type.to_s.upcase)
      end
    end

    def formatted_time(time)
      time.strftime("%Y%m%d%H%M%S")
    end

    def fields(txn_type)
      CCBill.configuration.datalink.field_list[txn_type] || FIELD_LIST_DEFAULTS[txn_type]
    end
  end
end