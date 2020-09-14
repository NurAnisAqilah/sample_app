class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      # Log the user in and redirect to the user's show page.
      log_in user
      redirect_to user
    else
      flash.now[:danger] = t "invalid_email_password_combination"
      render :new 
    end
  end

  def destroy
    log_out
    redirect_to_root_path
  end
end