# frozen_string_literal: true

default_keys = [
  {
    key: 'key',
    secret: 'secret'
  },
  {
    key: 'key1',
    secret: 'secret1'
  }
]

default_keys.each do |default_key|
  puts default_key[:key]
  unless RailsLti2Provider::Tool.find_by_uuid(default_key[:key])
    RailsLti2Provider::Tool.create!(uuid: default_key[:key], shared_secret: default_key[:secret], lti_version: 'LTI-1p0', tool_settings: 'none')
  end
end

default_tools = [
  {
    name: 'default',
    uid: 'key',
    secret: 'secret',
    redirect_uri: "http://#{Rails.configuration.url_host}/apps/default/auth/bbbltibroker/callback",
    scopes: 'api'
  },
  {
    name: 'rooms',
    uid: 'b21211c29d27',
    secret: '3590e00d7ebd',
    redirect_uri: "https://#{Rails.configuration.url_host}/apps/rooms/auth/bbbltibroker/callback",
    scopes: 'api'
  },
]

default_tools.each do |default_tool|
  unless Doorkeeper::Application.find_by_name(default_tool[:name])
    Doorkeeper::Application.create!(default_tool)
  end
end
