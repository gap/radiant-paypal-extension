require File.dirname(__FILE__) + '/../spec_helper'

describe PaypalSession do
  before(:each) do
    @paypal_session = PaypalSession.new
  end

  it "should be valid" do
    @paypal_session.should be_valid
  end
end
