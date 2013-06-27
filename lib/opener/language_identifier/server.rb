require 'sinatra/base'
require 'httpclient'
require 'uuidtools'

module Opener
  class LanguageIdentifier
    ##
    # A basic language identification server powered by Sinatra.
    #
    class Server < Sinatra::Base
      configure do
        enable :logging
      end

      configure :development do
        set :raise_errors, true
        set :dump_errors, true
      end

      ##
      # Provides a page where you see a textfield and you can post stuff
      #
      get '/' do
        erb :index
      end

      ##
      # Identifies a given text.
      #
      # @param [Hash] params The POST parameters.
      #
      # @option params [String] :text The text to identify.
      # @option params [TrueClass|FalseClass] :kaf Whether or not to use KAF
      #  output.
      # @option params [TrueClass|FalseClass] :extended Whether or not to use
      #  extended language detection.
      # @option params [Array<String>] :callbacks A collection of callback URLs
      #  that act as a chain. The results are posted to the first URL which is
      #  then shifted of the list.
      # @option params [String] :error_callback Callback URL to send errors to
      #  when using the asynchronous setup.
      #
      post '/' do
        if !params[:text] or params[:text].strip.empty?
          logger.error('Failed to process the request: no text specified')

          halt(400, 'No text specified')
        end

        callbacks = extract_callbacks(params[:callbacks])
        if callbacks.empty?
          process_sync
        else
          process_async(callbacks)
        end
      end

      private

      ##
      # Processes the request synchronously.
      #
      def process_sync
        output = identify_text(params[:text])

        content_type(:xml) if params[:kaf]

        body(output)
      #rescue => error
        #logger.error("Failed to identify the text: #{error.inspect}")

        #halt(500, error.message)
      end

      ##
      # Processes the request asynchronously.
      #
      # @param [Array] callbacks The callback URLs to use.
      #
      def process_async(callbacks)
        request_id = get_request_id
        output_url = callbacks.last
        Thread.new do
          identify_async(params[:text], request_id, callbacks, params[:error_callback])
        end

        erb :result, :locals => {:output_url => [output_url, request_id].join("/")}
      end

      ##
      # @param [String] text The text to identify.
      # @return [String]
      # @raise RuntimeError Raised when the language identification process
      #  failed.
      #
      def identify_text(text)
        identifier            = LanguageIdentifier.new(options_from_params)
        output, error, status = identifier.run(text)

        raise(error) unless status.success?

        return output
      end

      ##
      # Returns a Hash containing various GET/POST parameters extracted from
      # the `params` Hash.
      #
      # @return [Hash]
      #
      def options_from_params
        options = {}

        [:kaf, :extended].each do |key|
          options[key] = params[key]
        end

        return options
      end

      ##
      # Identifies the text and submits it to a callback URL.
      #
      # @param [String] text
      # @param [Array] callbacks
      # @param [String] error_callback
      #
      def identify_async(text, request_id, callbacks, error_callback = nil)
        begin
          output = identify_text(text)
        rescue => error
          logger.error("Failed to identify the text: #{error.message}")

          submit_error(error_callback, error.message) if error_callback

          return
        end

        url = callbacks.shift

        logger.info("Submitting results to #{url}")
        logger.info("Using callback URLs: #{callbacks.join(', ')}")

        begin
          process_callback(url, output, request_id, callbacks)
        rescue => error
          logger.error("Failed to submit the results: #{error.inspect}")

          submit_error(error_callback, error.message) if error_callback
        end
      end

      ##
      # @param [String] url
      # @param [String] text
      # @param [Array] callbacks
      #
      def process_callback(url, text, request_id, callbacks)
        HTTPClient.post(
          url,
          :body => {:text => text, :request_id => request_id, :'callbacks[]' => callbacks, :kaf => true}
        )
      end

      ##
      # @param [String] url
      # @param [String] message
      #
      def submit_error(url, message)
        HTTPClient.post(url, :body => {:error => message})
      end

      ##
      # Returns an Array containing the callback URLs, ignoring empty values.
      #
      # @param [Array|String] input
      # @return [Array]
      #
      def extract_callbacks(input)
        if !input.nil?
          callbacks = input.compact.reject(&:empty?)
          return callbacks
        else
          return []
        end
      end

      def get_request_id
        return params[:request_id] || UUIDTools::UUID.random_create
      end
    end # Server
  end # LanguageIdentifier
end # Opener
