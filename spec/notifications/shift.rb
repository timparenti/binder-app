include FakeSMS
RSpec.describe Shift, :type => :model do
  it 'should send message to booth chairs 1 hour before shift starts and 5 min after if someone does not show up' do
    Delayed::Job.count.should == 0
    #creating appropiate factory girls
    @type1 = FactoryGirl.create(:shift_type, :name => "Watch Shift")
    @upcoming= FactoryGirl.create(:shift, :shift_type_id => @type1.id, :ends_at => Time.local(2021,1,1,16,0,0), :starts_at => Time.zone.now + 2.hour)
    Delayed::Job.count.should == 2

    #destroy the objects
    @type1.destroy
    @upcoming.destroy

  end
end