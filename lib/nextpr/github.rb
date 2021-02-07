# frozen_string_literal: true

require "json"
require "net/http"

require_relative "../nextpr"

module NextPr
  class GitHub
    def initialize(token)
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "bearer #{token}"
      }.freeze
    end

    def get_ids(owner, repository)
      response = Net::HTTP.post(
        URI("https://api.github.com/graphql"),
        JSON.generate({ query: query(owner, repository) }),
        @headers
      )

      body = JSON::parse(response.body)

      # Auth errors are put directly in "message", not under and "errors" key
      raise body["message"] if body["message"]
      raise body["errors"].map { |error| error["message"] }.join("\n") if body["errors"]

      extract_ids(body)
    end

    private

    def query(owner, repository)
      <<~GRAPHQL
      query {
        repository(owner: "#{owner}", name: "#{repository}") {
          issues(last: 1) {
            edges {
              node {
                number
              }
            }
          },
          pullRequests(last: 1) {
            edges {
              node {
                number
              }
            }
          }
        }
      }
      GRAPHQL
    end

    def extract_ids(body)
      ["issues", "pullRequests"].map do |key|
        edges = body["data"]["repository"][key]["edges"]

        next 0 if edges.empty?

        edges[0]["node"]["number"]
      end
    end
  end
end
