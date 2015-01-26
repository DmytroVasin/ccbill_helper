require 'spec_helper'

RSpec.describe CCBill::DataLink do

  let(:client)  { CCBill::DataLink.new }

  let(:error_response)   { double(body: "Error: something went wrong") }
  let(:success_response) do
    double(body:
      [
        '"EXPIRE","0000","1234567890123456","2014-01-05","2014-01-20","N"',
        '"EXPIRE","0000","6543210987654321","2014-01-10","2014-01-15","Y"'
      ].join("\n")
    )
  end
  
  let(:start_time) { Time.parse("2014-01-01") }
  let(:end_time)   { Time.parse("2014-01-02") }
  let(:txn_types)  { [:expire] }
  let(:params)     { CCBill::DataLink.new.send(:build_params, start_time, end_time, txn_types) }


  before :all do
    CCBill.configure do |config|
      config.datalink_username = "datalink_guy"
      config.datalink_password = "datalink_secret"
    end
  end

  describe "parsing transactions response" do

    context "the request is successful" do

      let (:response) { client.transactions(start_time, end_time, txn_types) }

      before :each do
        allow(client).to receive(:connection) { double(get: success_response) }
      end

      it "returns an array" do
        expect(response).to be_a(Array)
      end

      it "returns all transactions" do
        expect(response.size).to eq 2
      end

      it "matches the column names and data correctly" do
        expect(response[0]).to match({
          transaction_type:     "EXPIRE",
          client_sub_account:   "0000",
          subscription_id:      "1234567890123456",
          expire_date:          "2014-01-05",
          cancel_date:          "2014-01-20",
          batched_transaction:  "N"
        })
      end
    end

    context "the request is unsuccessful" do
      before :each do
        allow(client).to receive(:connection) { double(get: error_response) }
      end

      it "raises an exception" do
        expect {
          client.transactions(start_time, end_time, [])
        }.to raise_error(CCBill::DataLinkError)
      end
    end
  end

end