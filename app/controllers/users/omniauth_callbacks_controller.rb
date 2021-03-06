# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.from_omniauth(request.env['omniauth.auth'])
        if @user.persisted?
          flash[:success] = I18n.t 'devise.omniauth_callbacks.success', kind: '#{provider}' if is_navigational_format?
          sign_in_and_redirect @user, event: :authentication
        else
          session['devise.#{provider}_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
          flash[:error] = I18n.t 'devise.omniauth_callbacks.failure', kind: '#{provider}', reason: @user.errors.full_messages.join("\n") if is_navigational_format?
          redirect_to new_user_registration_url
        end
      end
    }
  end

  %i[ google_oauth2 twitter facebook linkedin ].each do |provider|
    provides_callback_for provider
  end

  protected

  # The path used when OmniAuth fails
  def after_omniauth_failure_path_for(scope)
    super(scope)
  end
end
