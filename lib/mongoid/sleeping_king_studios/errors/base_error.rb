# lib/mongoid/sleeping_king_studios/errors/base_error.rb

require 'mongoid/sleeping_king_studios/errors'

module Mongoid::SleepingKingStudios::Errors
  # Base class for errors thrown by extensions in the
  # Mongoid::SleepingKingStudios namespace.
  class BaseError < StandardError
    DEFAULT_PROBLEM = 'An unknown error occurred.'

    def initialize problem = nil, details: nil, resolution: nil, summary: nil
      super()

      @problem    = problem || DEFAULT_PROBLEM
      @summary    = summary
      @details    = details
      @resolution = resolution
    end # method initialize

    attr_accessor :problem, :summary, :details, :resolution

    def message
      problem_string + summary_string + details_string + resolution_string
    end # method message

    private
    
    def details_string
      details ?
        "\nDetails:\n  #{details}" :
        ''
    end # method details_string

    def problem_string
      "Problem:\n  #{problem}"
    end # method problem_string

    def resolution_string
      resolution ?
        "\nResolution:\n  #{resolution}" :
        ''
    end # method resolution_string

    def summary_string
      summary ?
        "\nSummary:\n  #{summary}" :
        ''
    end # method summary_string
  end # class
end # module
