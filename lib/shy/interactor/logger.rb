# frozen_string_literal: true

require "logger"

module Shy
  module Interactor
    class Logger < ::Logger # rubocop:disable Style/Documentation
      def initialize(logdev = $stdout)
        super(logdev, progname:, formatter:)
      end

      private

      def formatter
        proc do |severity, time, progname, context_and_message|
          ctx, message = context_and_message
          Logger::Formatter.new.call severity, time, progname, "message=\"#{message}\" context=\"#{ctx}\"\n"
        end
      end

      def progname
        "Shy::Interactor"
      end
    end
  end
end
