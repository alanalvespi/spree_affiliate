module AffiliateCredits
include SMS 
  private

  def create_affiliate_credits(sender, recipient, event)
    #check if sender should receive credit on affiliate register
    if sender_credit_amount = SpreeAffiliate::Config["sender_credit_on_#{event}_amount".to_sym] and sender_credit_amount.to_f > 0 and event =="register"
      reason = Spree::StoreCreditReason.find_or_create_by_name("Referral Credits")
      type = Spree::StoreCreditType.find_or_create_by_name("Referral Credits")
      credit = sender.store_credits.find_by_store_credit_reason_id(reason.id)
      if credit.blank?
        
		credit = reason.store_credits.create({:amount => sender_credit_amount,
                         :remaining_amount => sender_credit_amount.to_f,
                         :user_id => sender.id,
                         :expiry => "2014-12-31 18:00:00", :applies_on => 1,:store_credit_type_id => type.id}, :without_protection => true)
	
      else
        credit.update_attributes(:amount => credit.amount+sender_credit_amount.to_f,
                               :remaining_amount => credit.remaining_amount+sender_credit_amount.to_f)
      end
      
      #Bonus credits
      if sender.affiliates.count == 25
        sender_credit_amount = SpreeAffiliate::Config["sender_credit_on_register_25_amount".to_sym] and sender_credit_amount.to_f > 0
        credit.update_attributes(:amount => credit.amount+sender_credit_amount.to_f,
                               :remaining_amount => credit.remaining_amount+sender_credit_amount.to_f)
      elsif sender.affiliates.count == 50
        sender_credit_amount = SpreeAffiliate::Config["sender_credit_on_register_50_amount".to_sym] and sender_credit_amount.to_f > 0
        credit.update_attributes(:amount => credit.amount+sender_credit_amount.to_f,
                               :remaining_amount => credit.remaining_amount+sender_credit_amount.to_f)
      elsif sender.affiliates.count == 100
        sender_credit_amount = SpreeAffiliate::Config["sender_credit_on_register_100_amount".to_sym] and sender_credit_amount.to_f > 0
        credit.update_attributes(:amount => credit.amount+sender_credit_amount.to_f,
                               :remaining_amount => credit.remaining_amount+sender_credit_amount.to_f)
      end
      log_event recipient.affiliate_partner, sender, credit, event
      notify_event recipient, sender, credit, event,sender_credit_amount
      UserMailers.user_purchased(sender,recipient,sender_credit_amount,"register","Say what! #{recipient.firstname} just joined Styletag. You've got Rs.#{sender_credit_amount} referral credits!").deliver
      UserMailers.user_notification(recipient,sender,sender_credit_amount,"register","#{sender.firstname} got Rs.#{sender_credit_amount} referral credits! Want some?").deliver
  end
  
   #check if sender should receive credit on affiliate purchase
  if sender_credit_amount = SpreeAffiliate::Config["sender_credit_on_#{event}_amount".to_sym] and sender_credit_amount.to_f > 0 && event=="purchase"
      reason = Spree::StoreCreditReason.find_or_create_by_name("Referral Credits")
      type = Spree::StoreCreditType.find_or_create_by_name("Referral Credits")
      credit = sender.store_credits.find_by_store_credit_reason_id(reason.id)
      if credit.blank?
        
		credit = reason.store_credits.create({:amount => sender_credit_amount,
                         :remaining_amount => sender_credit_amount.to_f,
                         :user_id => sender.id,
                         :expiry => "2014-12-31 18:00:00", :applies_on => 1,:store_credit_type_id => type.id}, :without_protection => true)
	
      else
        credit.update_attributes(:amount => credit.amount+sender_credit_amount.to_f,
                               :remaining_amount => credit.remaining_amount+sender_credit_amount.to_f)
      end
      log_event recipient.affiliate_partner, sender, credit, event
      notify_user recipient, sender, credit, event,sender_credit_amount
      UserMailers.user_purchased(sender,recipient,sender_credit_amount,"purchase","Lucky day! You've got Rs.#{sender_credit_amount} referral credits!").deliver
      UserMailers.user_notification(recipient,sender,sender_credit_amount,"purchase","#{sender.firstname} got Rs.#{sender_credit_amount} referral credits! Get yours too!").deliver
      #~ Spree::Order.cod_order_confirmation(Spree::Order.last,Spree::Order.last.number, "8951246163")
  end
  
    #check if affiliate should recevied credit on sign up
    if recipient_credit_amount = SpreeAffiliate::Config["recipient_credit_on_#{event}_amount".to_sym] and recipient_credit_amount.to_f > 0
      #reason = Spree::StoreCreditReason.find_or_create_by_name("Affiliate: #{event}")
      #type = Spree::StoreCreditType.find_or_create_by_name("Affiliate: #{event}")
      #credit = reason.store_credits.create({:amount => recipient_credit_amount,
      #                  :remaining_amount => recipient_credit_amount,
      #                  :user => recipient,:store_credit_type_id => type.id}, :without_protection => true)
      #
      #log_event recipient.affiliate_partner, recipient, credit, event
    end

  end

  def log_event(affiliate, user, credit, event)
    affiliate.events.create({:reward => credit, :name => event, :user => user}, :without_protection => true)
  end

def notify_user(recipient, user, credit, event,sender_credit_amount)
  str = "It pays to have friends! Your friend #{recipient.firstname} just shopped, and we are delighted to credit Rs.#{sender_credit_amount} into your Styletag Referral Credits. <a href='/invite'> Crave More, Invite More.</a>"
  Spree::Notification.create_notification(user.id,"<p>#{str}. <a href='/account#my-vouchers'>Click here to see your vouchers</a></p>")

  str = "You are destiny’s child! Your friend #{user.firstname} just got referral credits worth Rs.#{sender_credit_amount} because you just made your first purchase! Want some for yourself? <a href='/invite'>Invite your friends now.</a>"
  Spree::Notification.create_notification(recipient.id,"<p>#{str}. <a href='/account#my-vouchers'>Click here to see your vouchers</a></p>")

  #sms
  user_mob_no = user.addresses.last.phone rescue nil
  sms_text ="Your friend #{recipient.firstname} just shopped &amp; you've got Rs.1000 Styletag referral credits! Crave More, Invite More - www.styletag.com/invite"
  sms_notification(user, "#{user_mob_no}" , sms_text) unless user_mob_no.nil?

  recipient_mob_no = recipient.addresses.last.phone rescue nil
  sms_text = "#{user.firstname} just got Rs.1000 referral credits as you made your 1st buy! Want some? Invite now - www.styletag.com/invite"
  sms_notification(recipient, "#{recipient_mob_no}" , sms_text) unless recipient_mob_no.nil?

end

def notify_event(recipient, user, credit, event,sender_credit_amount)
  str = "It's your lucky day! Your friend #{recipient.firstname} just joined Styletag & we have credited Rs.#{sender_credit_amount} into your Styletag Referral Credits. <a href='/invite'>Hoard More, Invite More.</a>"
  Spree::Notification.create_notification(user.id,"<p>#{str}. <a href='/account#my-vouchers'>Click here to see your vouchers</a></p>")

  str = "You just made #{user.firstname}'s day awesome! #{user.firstname} just got referral credits worth Rs.#{sender_credit_amount} because you just joined Styletag. <a href='/invite'>Get Rs 1000 + 50 for every friend you INVITE.</a>"
  Spree::Notification.create_notification(recipient.id,"<p>#{str}. <a href='/account#my-vouchers'>Click here to see your vouchers</a></p>")

  #sms
  user_mob_no = user.addresses.last.phone rescue nil
  sms_text = "Your friend #{recipient.firstname} just joined Styletag &amp; you've got Rs.50 referral credits! Hoard More, Invite More - www.styletag.com/invite"
  sms_notification(user, "#{user_mob_no}" , sms_text) unless user_mob_no.nil?

  recipient_mob_no = recipient.addresses.last.phone rescue nil
  sms_text = "You made #{user.firstname}'s day by joining Styletag! #{user.firstname} got Rs.50 referral credits. Get Rs.1000+50 for each friend you INVITE - www.styletag.com/invite"
  sms_notification(recipient, "#{recipient_mob_no}" , sms_text) unless recipient_mob_no.nil?

end
                                                                                                                             ``

  def check_affiliate
    @user.reload if @user.present? and not @user.new_record?
    return if cookies[:ref_id].blank? || @user.nil? || @user.invalid?
    sender = Spree.user_class.find_by_ref_id(cookies[:ref_id])

    if sender
      sender.affiliates.create(:user_id => @user.id)

      #create credit (if required)
      @credited = create_affiliate_credits(sender, @user, "register")
    end

    #destroy the cookie, as the affiliate record has been created.
    cookies[:ref_id] = nil
  end


  def sms_notification(user, send_to, text)
    text = mobile_mess(text)
    tag = "credits"
    xml = get_xml(user.id, text, send_to, tag)
    pd = post_data(xml)
    puts pd.body
  end

  def mobile_mess(text)
    user_text=%Q|#{text}|%
        user_text
  end


  def get_xml(seq, text, send_to, send_tag)
    username = "intrepidonlneld"
    password = "iorpvtld"

    # Default metadata
    send_tag = "styltg"
    url = "http://api.myvaluefirst.com/psms/servlet/psms.Eservice2"
    encoded_xml = %Q|<?xml version="1.0" encoding="utf-8"?><!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1/psms/dtd/messagev12.dtd" ><MESSAGE VER="1.2"><USER USERNAME="#{username}" PASSWORD="#{password}"/><SMS UDH="0" CODING="1" TEXT="#{text}" PROPERTY="0" ID="#{seq}"><ADDRESS FROM="styltg" TO="#{send_to}" SEQ="#{seq}" TAG="#{send_tag}" /></SMS></MESSAGE>|%
        encoded_xml
  end

  def post_data(xml)
    url = "http://api.myvaluefirst.com/psms/servlet/psms.Eservice2"
    postData = Net::HTTP.post_form(URI.parse(url), {"data"=>xml,"action"=>"send"})
  end

end
