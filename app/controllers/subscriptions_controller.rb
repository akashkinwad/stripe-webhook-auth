class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subscriptions = current_user.subscriptions
  end
end
