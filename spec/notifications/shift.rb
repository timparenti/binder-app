include FakeSMS
RSpec.describe Shift, :type => :model do
  it 'should send message to booth chairs 1 hour before shift starts and 5 min after if someone does not show up' do
    #creating appropiate factory girls
    @type1 = FactoryGirl.create(:shift_type, :name => "Watch Shift")

    @upcoming = FactoryGirl.create(:shift, :shift_type_id => @type1.id, :ends_at => Time.local(2021,1,1,16,0,0), :starts_at => Time.zone.now + 2.hour)

    @current = FactoryGirl.create(:shift, :shift_type_id => @type3.id, :ends_at => Time.local(2020,1,1,16,0,0), :starts_at => Time.local(2016,1,1,13,4,0))

    @not_checked_in = FactoryGirl.create(:shift, :shift_type_id => @type2.id,  :required_number_of_participants => 1, :ends_at => Time.local(2001,1,1,16,0,0), :starts_at => Time.local(2000,1,1,14,10,0))
    @checked_in = FactoryGirl.create(:shift, :shift_type_id => @type2.id,  :required_number_of_participants => 2, :ends_at => Time.local(2001,1,1,16,0,0), :starts_at => Time.local(2000,1,1,14,10,0))
    FactoryGirl.create(:shift_participant, :shift => @checked_in)


    #this creates/starts downtime which should then send first notification
    @downtime = FactoryGirl.create(:organization_timeline_entry, :started_at => Time.now - 1.hour, :ended_at => nil)
    #just put @downtime for now, will update once FakeSMS is working
    expect(FakeSMS.messages).to eq(@downtime)
    #Update downtime and end it, which triggers second notification
    @downtime.update({:ended_at => Time.now})
    expect(FakeSMS.messages).to eq(@downtime)
    #destroy the objects
    @org.destroy
    @boothChair.destroy
    @membership.destroy
    @downtime.destroy
  end
end