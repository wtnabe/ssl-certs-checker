#! /usr/bin/env ruby

=begin

Usage: ruby command.rb settings.yaml

=end

# require `curl` executable
require 'yaml'
require 'time'

ISSUER_RE = /^\*  issuer: /

def conf_file
  @path = ARGV.first unless @path
end

def main
  sites.each do |domain|
    cert = select_cert(read_headers(domain))
    issuer = parse_item(:issuer, select_item(:issuer, cert))
    subject = parse_item(:subject, select_item(:subject, cert))
    puts [
      domain,
      issuer['O'],
      subject['O'],
      auto_renew?(issuer: issuer, subject: subject),
      expire_date(cert)
    ].join("\t")
  end
end

#
# [return] Array
#
def read_conf(path)
  conf = YAML.load_file(path)
  @sites = conf['sites']
  @auto_renew_certs = conf['auto_renew_certs']
end

#
# [return] Array
#
def sites
  read_conf(conf_file) unless @sites
  @sites
end

#
# [return] Array
#
def auto_renew_certs
  read_conf(conf_file) unless @auto_renew_certs
  @auto_renew_certs
end
  
#
# [param] String uri
# [return] String
#
def read_headers(uri)
  `curl -svk -o /dev/null https://#{uri} 2>&1`.lines.map(&:chomp).select {|line|
    line !~ /^[>}]/ && line !~ /^[<{]/
  }
end

#
# [param] Array
# [return] String
#
def select_cert(messages)
  detect = false
  cert = []
  
  messages.each { |message|
    if message !~ /^\*  /
      detect = false
    end
    if message =~ /^\* Server certificate:/
      detect = true
    end
      
    cert << message if detect
  }

  cert
end

def item_re(key)
  /^\*  #{key}: /
end

#
# [Array] cert
# [return] String
#
def select_item(key, cert)
  cert.select { |message| message =~ item_re(key) }.first
end

def parse_date()
end

#
# [param] String line
# [return] Hash
#
def parse_item(key, line)
  item = line.to_s

  Hash[*item.sub(item_re(key), '').split(/; /).map { |item|
    item.split(/=/)
  }.flatten]
end

#
# [param] Hash issuer
# [param] Hash subject
# [return] Boolean
#
def auto_renew?(issuer:, subject:)
  is_renew = (issuer['O'] && auto_renew_certs.include?(issuer['O'])) ||
             (subject['O'] && auto_renew_certs.include?(subject['O']))

  is_renew.nil? ? false : is_renew
end

#
# [param] String cert
# [return] String
#
def expire_date(cert)
  Time.parse(select_item(:expire_date.to_s.sub('_', ' '), cert).sub(item_re(:expire_date), ''))
end

def test_parse_issuer
  puts parse_item(:issuer, '*  issuer: C=US; O=DigiCert Inc; OU=www.digicert.com; CN=GeoTrust RSA CA 2018')
end

#test_parse_issuer

main
