# frozen_string_literal: true

require_relative "nextpr/github"

module NextPr
  VERSION = "0.1.0"

  class << self
    def find(token, owner, repository)
      github = GitHub.new(token)
      ids = github.get_ids(owner, repository)

      ids.max.next
    end
  end
end
