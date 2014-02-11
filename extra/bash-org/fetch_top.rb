require 'rss/2.0'
require 'cgi'
require 'net/http'
data = Net::HTTP.get(URI('http://bash.im/rss/'))
parsed = RSS::Parser.parse(data.gsub(/\< hr\>/, '< hr />'), false)
parsed.items.each { |x| puts CGI::unescapeHTML(x.description.gsub("\n", "").gsub("<br>", "\n")); puts "%\n" }
