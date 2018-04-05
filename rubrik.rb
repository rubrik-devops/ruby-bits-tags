$LOAD_PATH.unshift File.expand_path('../lib/', __FILE__)
require 'parseoptions.rb'
require 'pp'
require 'getCreds.rb'
require 'json'
require 'csv'
require 'uri'
require 'restCall.rb'
require 'getToken.rb'

date = DateTime.now.strftime('%Y-%m-%d.%H-%M-%S')


# BEGIN
Creds = getCreds();
Begintime=Time.now
Logtime=Begintime.to_i

# Global options
Options = ParseOptions.parse(ARGV)
r = Options.r
v = Options.v

if r
  vers=restCall(r ,"/api/v1/cluster/me",'','get', '')['version']
  puts "Rubrik CDM Version #{vers}" 
end

if v
  (token,sv) = get_token(v)
  header={}
  header = {"vmware-api-session-id" => "#{token}"}
  categories={}
  catIDs=restCall(sv ,"/rest/com/vmware/cis/tagging/category",'','get', header)['value'] # Get all tags
  catIDs.each do |id|
    t=restCall(sv ,"/rest/com/vmware/cis/tagging/category/id:#{id}",'','get', header)['value'] # Get all tags
    categories[t['id']] = t['name']
  end
    
  tags= {}
  tagIDs=restCall(sv ,"/rest/com/vmware/cis/tagging/tag",'','get', header)['value'] # Get all tags
  tagIDs.each do |id|
    t=restCall(sv ,"/rest/com/vmware/cis/tagging/tag/id:#{id}",'','get', header)['value'] # Get Tag Detail
    tags[t['id']] = {}
    tags[t['id']]['name'] = t['name']
    tags[t['id']]['category'] = t['category_id']
    tags[t['id']]['associations'] = []
    a=restCall(sv ,"/rest/com/vmware/cis/tagging/tag-association/id:#{id}?~action=list-attached-objects",'','post', header)['value'] # Get All Associations
    if a
      a.each do |b|
        vm=restCall(sv ,"/rest/vcenter/vm/#{b['id']}",'','get', header)['value'] # Get All Associations
        tags[t['id']]['associations']  << vm['name']
      end
    end
  end
  tags.each do |id,v|
    tags[id]['categoryname'] = categories[v['category']]
  end
  tags.each do |id,v|
    puts v['categoryname'] + "/" + v['name']
    puts "  " + v['associations'].to_s
  end

end

if Options.login 
   require 'getToken.rb'
end
