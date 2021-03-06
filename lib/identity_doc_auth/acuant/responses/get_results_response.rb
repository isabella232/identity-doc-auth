require 'identity_doc_auth/acuant/pii_from_doc'
require 'identity_doc_auth/acuant/result_codes'
require 'identity_doc_auth/response'

module IdentityDocAuth
  module Acuant
    module Responses
      class GetResultsResponse < IdentityDocAuth::Response
        attr_reader :config

        BARCODE_COULD_NOT_BE_READ_ERROR = 'The 2D barcode could not be read'.freeze

        def initialize(http_response, config)
          @http_response = http_response
          @config = config
          super(
            success: successful_result?,
            errors: error_messages_from_alerts,
            extra: {
              result: result_code.name,
              billed: result_code.billed,
              raw_alerts: raw_alerts,
            },
          )
        end

        # Explicitly override #to_h here because this method response object contains PII.
        # This method is used to determine what from this response gets written to events.log.
        # #to_h is defined on the super class and should not include any parts of the response that
        # contain PII. This method is here as a safegaurd in case that changes.
        def to_h
          {
            success: success?,
            errors: errors,
            exception: exception,
            result: result_code.name,
            billed: result_code.billed,
            raw_alerts: raw_alerts,
          }
        end

        # @return [DocAuth::Acuant::ResultCode::ResultCode]
        def result_code
          IdentityDocAuth::Acuant::ResultCodes.from_int(parsed_response_body['Result'])
        end

        def pii_from_doc
          return {} unless successful_result?

          IdentityDocAuth::Acuant::PiiFromDoc.new(parsed_response_body).call
        end

        private

        attr_reader :http_response

        def error_messages_from_alerts
          return {} if successful_result?

          unsuccessful_alerts = raw_alerts.filter do |raw_alert|
            alert_result_code = IdentityDocAuth::Acuant::ResultCodes.from_int(raw_alert['Result'])
            alert_result_code != IdentityDocAuth::Acuant::ResultCodes::PASSED
          end

          {
            results: unsuccessful_alerts.map { |alert| alert['Disposition'] }.uniq,
          }
        end

        def parsed_response_body
          @parsed_response_body ||= JSON.parse(http_response.body)
        end

        def raw_alerts
          parsed_response_body['Alerts'] || []
        end

        def successful_result?
          passed_result? || attention_with_barcode?
        end

        def passed_result?
          result_code == IdentityDocAuth::Acuant::ResultCodes::PASSED
        end

        def attention_with_barcode?
          return false unless result_code == IdentityDocAuth::Acuant::ResultCodes::ATTENTION

          raw_alerts.all? do |alert|
            alert_result_code = IdentityDocAuth::Acuant::ResultCodes.from_int(alert['Result'])

            alert_result_code == IdentityDocAuth::Acuant::ResultCodes::PASSED ||
              (alert_result_code == IdentityDocAuth::Acuant::ResultCodes::ATTENTION &&
               alert['Disposition'] == BARCODE_COULD_NOT_BE_READ_ERROR)
          end
        end
      end
    end
  end
end
