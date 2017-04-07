include FakeSMS
RSpec.describe OrganizationTimelineEntry, :type => :model do
  it 'should send message to booth chairs for an org when their downtime starts and ends' do
    #creating appropiate factory girls
    @org = FactoryGirl.create(:organization, :name => 'SCC')
    @boothChair = FactoryGirl.create(:participant, :andrewid => 'erbob', :phone_number => '3143242099')
    @membership = FactoryGirl.create(:membership, :organization => @org, :participant => @boothChair)
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