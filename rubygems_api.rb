require "rexml/document"
require 'json'
require 'open-uri'

def to_xml(query, gems)
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new('1.0', 'UTF-8')
  items = doc.add_element("items")
  gems.each do |g|
    gem_info = "#{g[:name]} #{g[:version]}"
    name_and_version_for_gemfile = "gem '#{g[:name]}', '~> #{g[:version]}'"
    item = items.add_element('item', {'arg' => name_and_version_for_gemfile, 'uid' => ''})
    item.add_element('title').add_text(gem_info)
    item.add_element('subtitle').add_text("#{g[:info]} by #{g[:authors]}")
    item.add_element('icon').add_text('rubygems_icon.png')
  end
  doc.to_s
end

query = ARGV[0]
url   = "https://rubygems.org/api/v1/search.json?query=#{query}"

gems  = JSON.parse(open(url).read).map do |g|
  {
    name:              g['name'],
    info:              g['info'],
    authors:           g['authors'],
    version:           g['version'],
    downloads:         g['downloads'],
    version_downloads: g['version_downloads'],
  }
end

# gems = gems.sort { |a, b| a[:downloads] <=> b[:downloads] }.reverse

puts to_xml(query, gems)
