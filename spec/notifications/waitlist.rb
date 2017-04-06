#require 'rails_helper'
RSpec.describe Checkout, :type => :model do 
	it 'should send message to next person on waitlist once checking in a tool' do
     	@org = FactoryGirl.create(:organization)
  	  	@person = FactoryGirl.create(:participant, :andrewid => 'erbob', :phone_number => '3143242099')
      	@person2 = FactoryGirl.create(:participant, :andrewid => 'ersam', :phone_number => '1234567899')
      	@saw = FactoryGirl.create(:tool_type, name: 'Saw')
      	@t1 = FactoryGirl.create(:tool, barcode: 1111, tool_type: @saw)
      	@checkout = FactoryGirl.create(:checkout, :checked_in_at => nil, :checked_out_at => Time.now, organization: @org, participant: @person, tool: @t1)
      	@wait1 = FactoryGirl.create(:tool_waitlist, :tool_type_id => @saw.id, :participant_id => @person2.id) 
      	#update checkout itself to start the notify
      	@checkout.checked_in_at = Time.now
    	@checkout.save!
    	#put :update, :id => @checkout.id, :checkout => @checkout.attributes = { :checked_in_at => Time.now }
    	expect(FakeSms.messages.last.num).to eq('1234567899')
    	#destroy the objects 
    	@org.destroy
  	  	@person.destroy
      	@person2.destroy
      	@saw.destroy
      	@t1.destroy
      	@checkout.destroy
      	@wait1.destroy
    	#response.should be_successful
    end 

end 