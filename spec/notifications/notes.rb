include FakeSMS
RSpec.describe Event, :type => :model do
  it 'should send notification ot participant once a note is posted to them' do
    #creating appropiate factory girls
    @person = FactoryGirl.create(:participant, :andrewid => 'erbob', :phone_number => '3143332222')
    #this creates note which should then send first notification
    @note = FactoryGirl.create(:event, :participant => @person)
    expect(FakeSMS.messages).to eq(@note)
    @note2 = FactoryGirl.create(:event, :participant => @person2)
    #this should still be the number since when no one was assigned this note
    expect(FakeSMS.messages.last.num).to eq(@note)
    #destroy the objects
    @person.destroy
    @note.destroy
    @note2.destroy
  end
end