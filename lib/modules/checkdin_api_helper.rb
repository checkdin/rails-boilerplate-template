module CheckdinApiHelper

  def checkdin_api_client
    Checkdin::Client.new(
      client_id: Rails.application.secrets.client_identifier,
      client_secret: Rails.application.secrets.client_secret,
      api_url: Rails.application.secrets.api_url
    )
  end

  def create_checkdin_user(user)
    checkdin_api_client.create_user(
      identifier: user.identifier,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      campaign_id: Rails.application.secrets.campaign_id
    )
  end

  def checkdin_user_bridge
    Checkdin::UserBridge.new(
      client_identifier: Rails.application.secrets.client_identifier,
      bridge_secret: Rails.application.secrets.shared_authentication_secret,
      checkdin_landing_url: Rails.application.secrets.checkdin_landing_url
    )
  end

  def facebook_login_url
    identifier = User.build_identifier("")
    checkdin_user_bridge.login_url(
      email: "",
      user_identifier: identifier,
      authentication_action: "signup_facebook",
      campaign_id: Rails.application.secrets.campaign_id
    )
  end

  def valid_authentication_request? provided_digest
    return false if provided_digest.blank?
    digester = CheckdinRequestDigester.new
    correct_digest = digester.digest_request(params_for_digest)
    SecureCompare.compare(correct_digest, provided_digest)
  end

  def create_checkdin_custom_activity user, custom_activity_node_id
    checkdin_api_client.create_custom_activity(
      custom_activity_node_id: custom_activity_node_id,
      user_id: user.checkdin_user_fk,
      email: user.email,
      campaign_id: Rails.application.secrets.campaign_id
    )
  end

  private

  def params_for_digest
    params.slice(
      "auth_status",
      "auth_timestamp",
      "authentication_action",
      "user_id",
      "client_uid",
      "campaign_id",
      "existing_client_uid"
    )
  end

end
