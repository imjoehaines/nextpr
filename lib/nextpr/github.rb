# frozen_string_literal: true

require_relative "../nextpr"

module NextPr
  class GitHub
    ENDPOINT = URI("https://api.github.com/graphql")

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
  end
end
