Spree::CheckoutController.class_eval do
  include AffiliateCredits

  private

  def after_complete
    if !Spree::Affiliate.where(partner_id: spree_current_user.id).empty? && (@order.state == 'complete')
      sender = Spree::User.find(Spree::Affiliate.where(partner_id: spree_current_user.id).first.user_id)

      #create credit (if required)
      create_affiliate_credits(sender, spree_current_user, "purchase")
  end
end

end

    
    
    