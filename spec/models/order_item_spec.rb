require File.dirname(__FILE__) + '/../spec_helper'

describe OrderItem do
  before(:each) do
    @order_item = OrderItem.new
  end

  it "should be valid" do
    @order_item.should be_valid
  end
end
