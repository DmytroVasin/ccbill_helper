require 'spec_helper'

RSpec.describe CCBill::DataLink do

  let(:subject) { CCBill::DataLink.new }
  let(:client)  { subject }

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

  describe "making the request" do
    it "should make a request to ccbill" do
      #Faraday.stub(:get).and_return(success_response)
      #Faraday.should_receive(:get).with(CCBill::DataLink::DATALINK_URL, params)
      #client.transactions(start_time, end_time, txn_types)
    end
  end

  describe "parsing transactions response" do

    context "the request is successful" do

      let (:response) { client.transactions(start_time, end_time, txn_types) }

      before :each do
        Faraday::Connection.any_instance.stub(:get).and_return(success_response)
      end

      it "returns an array" do
        response.should be_a(Array)
      end

      it "returns all transactions" do
        response.size.should == 2
      end

      it "matches the column names and data correctly" do
        response[0][:transaction_type].should    eq "EXPIRE"
        response[0][:client_sub_account].should  eq "0000"
        response[0][:subscription_id].should     eq "1234567890123456"
        response[0][:expire_date].should         eq "2013-01-05"
        response[0][:cancel_date].should         eq "2013-01-20"
        response[0][:batched_transaction].should eq "N"
      end
    end

    context "the request is unsuccessful" do
      before :each do
        Faraday::Connection.any_instance.stub(:get).and_return(error_response)
      end

      it "raises an exception" do
        expect {
          client.transactions(start_time, end_time, [])
        }.to raise_error(CCBill::DataLinkError)
      end
    end
  end

end