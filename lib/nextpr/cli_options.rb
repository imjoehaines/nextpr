# frozen_string_literal: true

require "optparse"

require_relative "../nextpr"
require_relative "git"

module NextPr
  class CliOptions
    class << self
      Options = Struct.new(:quiet, :token, :owner, :repository) do
        def quiet?
          quiet == true
        end

        def token
          self[:token] || ENV["NEXTPR_TOKEN"]
        end

        def valid?
          token != nil && owner != nil && repository != nil
        end

        def invalid
          return [] if valid?

          invalid_options = []
          invalid_options << "token" if token.nil?
          invalid_options << "owner" if owner.nil?
          invalid_options << "repository" if repository.nil?

          invalid_options
        end
      end

      def parse(command, arguments)
        options = Options.new

        parser = OptionParser.new do |parser|
          parser.banner = <<~USAGE
            nextpr v#{NextPr::VERSION}
            Usage: #{command} <owner> <repository> --token <token>"
          USAGE

          parser.on("-q", "--quiet", "Quiet output - only print the next PR number")
          parser.on("-t<token>", "--token <token>", "GitHub personal access token")

          parser.on("-h", "--help", "Print this help") do
            puts parser
            exit
          end

          parser.on("-v", "--version", "Print nextpr version") do
            puts "nextpr v#{NextPr::VERSION}"
            exit
          end
        end

        parser.parse!(arguments, into: options)

        case arguments.length
        when 0
          options.owner, options.repository = NextPr::Git.detect_repository
        when 1
          options.owner, options.repository = arguments[0].split("/", 2)
        else
          options.owner, options.repository = arguments
        end

        return options if options.valid?

        puts <<~ERROR.chomp
          Invalid options!
          Missing required arguments: #{options.invalid.join(", ")}

          #{parser}
        ERROR

        exit
      end
    end
  end
end
