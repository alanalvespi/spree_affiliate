Spree::UserRegistrationsController.class_eval do
  include AffiliateCredits

  after_filter :check_affiliate, :only => :create
  
  
  def new
    if params[:ref_id]
      cookies.permanent[:ref_id] = params[:ref_id]
      cookies.permanent[:src] = "referral"
    end
    super
  end

  private

  def check_affiliate
    return if cookies[:ref_id].blank? || @user.invalid?
    sender = Spree::User.find_by_ref_id(cookies[:ref_id])

    if sender
      sender.affiliates.create(:user_id => @user.id)

      #create credit (if required)
      create_affiliate_credits(sender, @user, "register")
    end

    #destroy the cookie, as the affiliate record has been created.
    cookies[:ref_id] = nil
  end
end
