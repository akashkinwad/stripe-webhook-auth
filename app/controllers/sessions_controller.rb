class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(session_params[:email], session_params[:password])
    if user
      session[:user_id] = user.id
      redirect_to subscriptions_path
    else
      flash[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  private

  def session_params
    params.permit(:email, :password)
  end
end
