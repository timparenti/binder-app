# lib/fake_sms.rb

module FakeSMS
  Message = Struct.new(:num, :msg)
  @messages = []

  def self.send_sms(num, msg)
    @messages << Message.new(num, msg)
  end

  def self.messages
    @messages
  end
end