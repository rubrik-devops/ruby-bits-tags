require 'optparse'
require 'optparse/time'
require 'ostruct'
class ParseOptions

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  def self.parse(args)
  options = OpenStruct.new

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: rubrik.rb [options]"

    opts.separator ""
    opts.separator "Specific options:"
    opts.on('-l', '--login', "Perform no operations but return authentication token") do |login|
      options[:login] = login;
    end
    opts.separator ""
    opts.separator "Common options:"
    opts.on('-r', '--rubrik [Address]', "Rubrik Cluster .creds name") do |o|
      options[:r] = o;
    end
    opts.on('-v', '--vcenter [Address]', "vCenter .creds name") do |o|
      options[:v] = o;
    end
    opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
    end
  end
  opt_parser.parse!(args)
   options
  end
end
