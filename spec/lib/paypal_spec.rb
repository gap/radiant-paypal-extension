require File.dirname(__FILE__) + '/../spec_helper'

describe 'Paypal' do
  dataset :pages
  
  describe '<r:sandbox>' do
    it 'should render the correct HTML' do
      tag = '<r:sandbox />'
      
      expected = "We bought something"
    
      pages(:home).should render(tag).as(expected)
    end
  end

end

