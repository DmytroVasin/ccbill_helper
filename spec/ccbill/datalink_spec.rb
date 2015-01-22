require 'spec_helper'

RSpec.describe CCBill::DataLink do

  let(:client)  { CCBill::DataLink.new }

  let(:error_response)   { double(body: "Error: something went wrong") }
  let(:success_response) do
    double(body:
      [
        '"EXPIRE","0000","1234567890123456","2013-01-05","2013-01-20","N"',
        '"EXPIRE","0000","6543210987654321","2013-01-10","2013-01-15","Y"'
      ].join("\n")
    )
  end
  
  let(:start_time) { Time.parse("2013-01-01") }
  let(:end_time)   { Time.parse("2013-01-02") }
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
        # response[0][:transaction_type].should    eq "EXPIRE"
        # response[0][:client_sub_account].should  eq "0000"
        # response[0][:subscription_id].should     eq "1234567890123456"
        # response[0][:expire_date].should         eq "2013-01-05"
        # response[0][:cancel_date].should         eq "2013-01-20"
        # response[0][:batched_transaction].should eq "N"
        skip 
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