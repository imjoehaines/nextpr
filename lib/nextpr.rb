# frozen_string_literal: true

require "json"
require "net/http"

require_relative "nextpr/github"

module NextPr
  VERSION = "0.1.0"

  class << self
    def find(token, owner, repository)
      github = GitHub.new
      query = github.query(owner, repository)

      response = Net::HTTP.post(
        GitHub::ENDPOINT,
        JSON.generate({ query: query }),
        {
          "Content-Type" => "application/json",
          "Authorization" => "bearer #{token}"
        }
      )

      body = JSON::parse(response.body)

      raise body["errors"].to_s if body["errors"]

      issueNumber = body["data"]["repository"]["issues"]["edges"][0]["node"]["number"]
      prNumber = body["data"]["repository"]["pullRequests"]["edges"][0]["node"]["number"]

      [issueNumber, prNumber].max + 1
    end
  end
end
