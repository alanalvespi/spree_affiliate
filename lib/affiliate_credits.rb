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
      UserMailers.user_purchased(sender,recipient,sender_credit_amount,"register","Congratulations! You've got store credits!").deliver
      UserMailers.user_notification(recipient,sender,sender_credit_amount,"register","Get your friends to join Styletag & win store credits!").deliver
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
      UserMailers.user_purchased(sender,recipient,sender_credit_amount,"purchase","Congratulations! You've got store credits!").deliver
      UserMailers.user_notification(recipient,sender,sender_credit_amount,"purchase","Ask your friends to shop on Styletag & get store credits").deliver
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
  str = "It pays to have friends! <br /> Your friend #{recipient.firstname} just shopped, <br />and we are delighted to credit Rs.#{sender_credit_amount} <br />into your Styletag Referral Credits.<br /> Crave More, Invite More <br />www.styletag.com/invite"
  Spree::Notification.create_notification(user.id,"#{str}. <a href='/account#my-vouchers'>Know More</a>")

  str = "You are destiny’s child! <br />Your friend #{user.firstname} <br />just got referral credits <br />worth Rs. #{sender_credit_amount} because you <br />just made your first purchase! <br />Want some for yourself? Invite your friends now - <br />www.styletag.com/invite"
  Spree::Notification.create_notification(recipient.id,"#{str}. <a href='/account#my-vouchers'>Know More</a>")
end

def notify_event(recipient, user, credit, event,sender_credit_amount)
  str = "It's your lucky day! <br />Your friend #{recipient.firstname} <br />just joined Styletag & we have <br />credited Rs. #{sender_credit_amount} into your Styletag <br />Referral Credits. Hoard More, <br />Invite More -www.styletag.com/invite"
  Spree::Notification.create_notification(user.id,"#{str}. <a href='/account#my-vouchers'>Know More</a>")

  str = "You just made #{user.firstname}'s day awesome! <br />#{user.firstname} just got referral credits <br />worth Rs. #{sender_credit_amount} because you just <br />joined Styletag. Get Rs 1000 + 50 <br />for every friend you INVITE - <br />www.styletag.com/invite"
  Spree::Notification.create_notification(recipient.id,"#{str}. <a href='/account#my-vouchers'>Know More</a>")
end


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
end
