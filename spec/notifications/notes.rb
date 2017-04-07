include FakeSMS
RSpec.describe Event, :type => :model do
  it 'should send notification ot participant once a note is posted to them' do
    #creating appropiate factory girls
    @person = FactoryGirl.create(:participant, :andrewid => 'erbob', :phone_number => '3143332222')
    #this creates note which should then send first notification
    @note = FactoryGirl.create(:event, :participant)
    expect(FakeSMS.messages).to eq(@note)
    #destroy the objects
    @person.destroy
    @note.destroy
  end
end