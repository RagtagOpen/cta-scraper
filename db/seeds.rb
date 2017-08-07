admin = Admin.find_or_initialize_by(email: 'a@example.com')
admin.password = 'password123'
admin.save

ScrapeFail.create!(
  "status_code"=>"500",
  "message"=>"500 Internal Server Error",
  "backtrace"=>
  ["/Users/goober/.rbenv/versions/2.4.0/lib/ruby/gems/2.4.0/gems/rest-client-2.0.1/lib/restclient/abstract_response.rb:103:in `return!'",
   "/Users/goober/.rbenv/versions/2.4.0/lib/ruby/gems/2.4.0/gems/rest-client-2.0.1/lib/restclient/request.rb:809:in `process_result'",
   "/Users/goober/.rbenv/versions/2.4.0/lib/ruby/gems/2.4.0/gems/rest-client-2.0.1/lib/restclient/request.rb:725:in `block in transmit'",
   "/Users/goober/.rbenv/versions/2.4.0/lib/ruby/2.4.0/net/http.rb:877:in `start'"],
   "scrape_attrs"=>
  {"free"=>false,
   "title"=>
  "Join EMILY's List President Stephanie Schriock and special guest Congresswoman Jacky Rosen at our 2017 Ignite Change Luncheon in San Francisco!",
    "location"=>
  {"region"=>"CA", "locality"=>"San Francisco", "postal_code"=>"94108", "address_lines"=>["The Fairmont Hotel", "950 Mason Street"]},
    "start_date"=>"2017-10-13T11:00:00.000+00:00",
    "browser_url"=>"https://secure.emilyslist.org/page/contribute/western-regional-luncheon",
    "origin_system"=>"Emily's List"},
    "active"=>true
)
