# frozen_string_literal: true

require_relative "../nextpr"

module NextPr
  class Git
    class << self
      def detect_repository
        raw = `git remote --verbose` rescue nil

        # The output can be empty if it errored, e.g. if this isn't a git repo
        return if raw.nil? || raw.empty?

        parse(raw)
      end

      private

      def parse(raw)
        github_remotes = raw.split("\n")
          .filter { |line| line.include?("github.com") }
          .filter { |line| line.end_with?("(push)") }

        return if github_remotes.count != 1

        match = github_remotes.first.match(/github\.com.(?<owner>.+)\/(?<repository>.+)\.git/)

        return if match.nil?

        [match[:owner], match[:repository]]
      end
    end
  end
end
