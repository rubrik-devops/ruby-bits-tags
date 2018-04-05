# Establish Token for subsequent requests during this run
# No arguments needed

require 'base64'
require 'json'
require 'faraday'
require 'base64'

def get_token(server)
  rh=Creds[server]
  sv = rh['servers']
  un = rh['username']
  pw = rh['password']
  if Options.v == server 
    conn = Faraday.new(:url => 'https://' + sv[0])
    conn.basic_auth(un, pw)
    conn.ssl.verify = false
    response = conn.post '/rest/com/vmware/cis/session'
    if response.status != 200
       msg = JSON.parse(response.body)['message']
       raise "vCenter - Unable to authenticate (#{msg})"
    else
      token = JSON.parse(response.body)['value']
      return token,sv
    end
  else
    return un,pw,sv
  end
end
