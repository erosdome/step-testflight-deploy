def to_boolean(s)
  !!(s =~ /^(true|t|yes|y|1)$/i)
end

curl = ["/usr/bin/curl http://testflightapp.com/api/builds.json"]
    
# Ipa
unless File.exists?(ENV['CONCRETE_IPA_PATH'])
  puts "No IPA found to deploy"
  exit!
end
curl << "-F file=@\"#{ENV['CONCRETE_IPA_PATH']}\""

# API token
unless ENV['TESTFLIGHT_API_TOKEN']
  puts "No API token found"
  exit!
end
curl << "-F api_token='#{ENV['TESTFLIGHT_API_TOKEN']}'"

# Team token
unless ENV['TESTFLIGHT_TEAM_TOKEN']
  puts "No team token found"
  exit!
end
curl << "-F team_token='#{ENV['TESTFLIGHT_TEAM_TOKEN']}'"

# dSYM
if File.exists?(ENV['CONCRETE_DSYM_PATH'])
  curl << "-F dsym=@\"#{ENV['CONCRETE_DSYM_PATH']}\""
end

# Notes
notes = ENV['TESTFLIGHT_NOTES']
notes ||= "Automatic build with Concrete"
curl << "-F notes=\"#{notes}\""

# Notify
curl << "-F notify=#{to_boolean(ENV['TESTFLIGHT_NOTIFY']) ? "True" : "False"}"

# Replace
curl << "-F replace=True" if to_boolean(ENV['TESTFLIGHT_REPLACE'])

# Distribution lists
curl << "-F distribution_lists=\"#{ENV['TESTFLIGHT_DISTRIBUTION_LIST']}\"" if ENV['TESTFLIGHT_DISTRIBUTION_LIST']

puts "$ curl.join(' ')"
`#{curl.join(' ')}`
exit $?.to_i