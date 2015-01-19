require 'spec_helper'

RSpec.describe CCBill::DynamicPricingForm do
  describe "#valid?" do
    context "form is for single payment (not recurring)" do
      context "is invalid" do
        let(:df) { CCBill::DynamicPricingForm.new("aaa-123", {}) }

        it "fails if missing a required field" do
          expect(df.valid?).to be_falsey
        end

        it "lists errors" do
          df.valid?
          expect(df.errors).to_not be_empty
        end
      end

      context "is valid" do
        let(:df) do
          CCBill::DynamicPricingForm.new("aaa-123", {
            account: "12345",
            initial_price: 1.23,
            initial_period: 30
          })
        end

        it "succeeds if all required fields included" do
          expect(df.valid?).to be_truthy
        end
        
        it "lists no errors" do
          df.valid?
          expect(df.errors).to be_empty
        end
      end
    end

    context "form is for recurring payment" do
      context "is invalid" do
        let(:df) do CCBill::DynamicPricingForm.new("aaa-123", {
            initial_price: 1.23,
            recurring_period: 15
          }) 
        end

        it "fails if missing a required field" do
          expect(df.valid?).to be_falsey
        end

        it "lists errors" do
          df.valid?
          expect(df.errors).to_not be_empty
        end
      end

      context "is valid" do
        let(:df) do
          CCBill::DynamicPricingForm.new("aaa-123", {
            account: "12345",
            initial_price: 1.23,
            initial_period: 30,
            recurring_price: 10,
            recurring_period: 30,
            rebills: 99
          })
        end

        it "succeeds if all required fields included" do
          expect(df.valid?).to be_truthy
        end
        
        it "lists no errors" do
          df.valid?
          expect(df.errors).to be_empty
        end
      end
    end
  end

  describe "#digest" do
    
    context "non-recurring" do
      it "returns salted md5 of field values" do
        CCBill.configure { |config| config.salt = "abc123" }
        df = CCBill::DynamicPricingForm.new("aaa-123", {
          initial_price: 1.23,
          initial_period: 30
        })
        expect(df.send(:digest)).to eq Digest::MD5.hexdigest("1.2330USDabc123")
      end
    end

    context "recurring" do
      it "returns salted md5 of field values" do
        CCBill.configure { |config| config.salt = "abc123" }
        df = CCBill::DynamicPricingForm.new("aaa-123", {
          initial_price: 1.23,
          initial_period: 30,
          recurring_price: 1,
          recurring_period: 10,
          rebills: 99
        })

        expect(df.send(:digest)).to eq Digest::MD5.hexdigest("1.233011099USDabc123")
      end
    end
  end

  describe "#url" do
    it "should raise when missing fields" do
      df = CCBill::DynamicPricingForm.new("aaa-123", {})
      expect { df.url }.to raise_error(CCBill::DynamicPricingError)
    end

    it "points to the sandbox when in test mode" do
      CCBill.configure { |config| config.mode = :test }
      df = CCBill::DynamicPricingForm.new("aaa-123", {
        initial_price: 1.23,
        initial_period: 30
      })

      expect(df.url).to include("https://sandbox-api.ccbill.com")
    end

    it "points to the live server when not in test mode" do
      CCBill.configure { |config| config.mode = :live }
      df = CCBill::DynamicPricingForm.new("aaa-123", {
        initial_price: 1.23,
        initial_period: 30
      })

      expect(df.url).to include("https://api.ccbill.com")
    end


  end
end