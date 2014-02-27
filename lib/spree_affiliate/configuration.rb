module SpreeAffiliate
  class Configuration < Spree::Preferences::Configuration
    preference :sender_credit_on_purchase_amount, :decimal, :default => 0.0
    preference :sender_credit_on_register_amount, :decimal, :default => 0.0
    preference :recipient_credit_on_register_amount, :decimal, :default => 0.0
    preference :recipient_credit_on_purchase_amount, :decimal, :default => 0.0
    preference :sender_credit_on_register_25_amount, :decimal, :default => 0.0
    preference :sender_credit_on_register_50_amount, :decimal, :default => 0.0
    preference :sender_credit_on_register_75_amount, :decimal, :default => 0.0
    preference :sender_credit_on_register_100_amount, :decimal, :default => 0.0
  end
end
