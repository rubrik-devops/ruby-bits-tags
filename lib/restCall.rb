require 'net/https'
require 'getToken.rb'

def restCall(server,endpoint,l,type,header)
  begin
    endpoint = URI.encode(endpoint)
    if header.to_s.empty? # Rubrik and Basic Auth
      (u,pw,sv) = get_token(server)
      conn = Faraday.new(:url => 'https://' + sv.sample(1)[0], request: {
        open_timeout: 5,   # opening a connection
        timeout: 360         # waiting for response
        })
      conn.basic_auth u, pw
      conn.headers['Authorization']
    elsif header # vCenter API Auth
      conn = Faraday.new(:url => 'https://' + server.sample(1)[0], request: {
        open_timeout: 5,   # opening a connection
        timeout: 360         # waiting for response
        })
      header.each do |k,v|
        conn.headers[k] = v
      end
    end
    conn.ssl.verify = false
    response = conn.public_send(type) do |req|
      req.url endpoint
      req.headers['Content-Type'] = 'application/json'
      req.body  = l.to_json
    end
    if response.status !~ /202|200/
      begin
        return JSON.parse(response.body)
      rescue 
        return "Endpoint #{response.url} returned #{response.status}"
      end
    end
  rescue Faraday::ConnectionFailed
    @error = "There was a timeout. Please try again."
  end

end
