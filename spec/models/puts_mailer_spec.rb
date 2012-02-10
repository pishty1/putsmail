require 'spec_helper'

describe PutsMail do
  
  fixtures :users
  
  it 'should puts mail' do
    apu = users(:apu)
    puts_mail = PutsMail.new
    subject = 'Hello Apu'
    body = 'Are you interested in new oportunities?'
    mail_counter = Property.mail_counter
    puts_mail.puts_mail(apu.mail, subject, body)    
    puts_mail.valid?.should be_true
    (mail_counter + 1).should eql(Property.mail_counter)
  end
  
  it 'should not puts mail with invalid mail' do
    apu = users(:apu)
    puts_mail = PutsMail.new
    mail_counter = Property.mail_counter
    puts_mail.puts_mail(apu.mail, 'Hello Apu', nil)
    mail_counter.should eql(Property.mail_counter)
    puts_mail.valid?.should be_false
    puts_mail.errors['body'].should eql("can't be blank")
  end
  
  it 'should not puts mail with invalid to' do
    # PEDING test nil mail
    # puts_mail = PutsMail.new
    # puts_mail.puts_mail(nil, nil, 'Hello Apu', 'Are you interested in new oportunities?')
    # puts_mail.valid?.should be_false
    # puts_mail.errors['to'].should eql("can't be blank")
    # puts_mail.errors['token'].should eql("can't be blank")
  end
  
end
