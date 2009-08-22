require File.dirname(__FILE__) + '/../spec_helper'

describe Products do
  before(:each) do
    @products = Products.new
  end

  it "should be valid" do
    @products.should be_valid
  end
end
