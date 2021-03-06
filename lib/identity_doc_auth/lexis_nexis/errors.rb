module IdentityDocAuth
  module LexisNexis
    module Errors
      BARCODE_CONTENT_CHECK = 'barcode_content_check'
      BARCODE_READ_CHECK = 'barcode_read_check'
      BIRTH_DATE_CHECKS = 'birth_date_checks'
      CONTROL_NUMBER_CHECK = 'control_number_check'
      DOC_CROSSCHECK = 'doc_crosscheck'
      DOC_NUMBER_CHECKS = 'doc_number_checks'
      EXPIRATION_CHECKS = 'expiration_checks'
      FULL_NAME_CHECK = 'full_name_check'
      GENERAL_ERROR_LIVENESS = 'general_error_liveness'
      GENERAL_ERROR_NO_LIVENESS = 'general_error_no_liveness'
      ID_NOT_RECOGNIZED = 'id_not_recognized'
      ID_NOT_VERIFIED = 'id_not_verified'
      ISSUE_DATE_CHECKS = 'issue_date_checks'
      MULTIPLE_BACK_ID_FAILURES = 'multiple_back_id_failures'
      MULTIPLE_FRONT_ID_FAILURES = 'multiple_front_id_failures'
      REF_CONTROL_NUMBER_CHECK = 'ref_control_number_check'
      SELFIE_FAILURE = 'selfie_failure'
      SEX_CHECK = 'sex_check'
      VISIBLE_COLOR_CHECK = 'visible_color_check'
      VISIBLE_PHOTO_CHECK = 'visible_photo_check'

      ALL = [
        BARCODE_CONTENT_CHECK,
        BARCODE_READ_CHECK,
        BIRTH_DATE_CHECKS,
        BIRTH_DATE_CHECKS,
        CONTROL_NUMBER_CHECK,
        DOC_CROSSCHECK,
        DOC_NUMBER_CHECKS,
        EXPIRATION_CHECKS,
        FULL_NAME_CHECK,
        GENERAL_ERROR_LIVENESS,
        GENERAL_ERROR_NO_LIVENESS,
        ID_NOT_RECOGNIZED,
        ID_NOT_VERIFIED,
        ISSUE_DATE_CHECKS,
        MULTIPLE_BACK_ID_FAILURES,
        MULTIPLE_FRONT_ID_FAILURES,
        REF_CONTROL_NUMBER_CHECK,
        SELFIE_FAILURE,
        SEX_CHECK,
        VISIBLE_COLOR_CHECK,
        VISIBLE_PHOTO_CHECK,
      ].freeze
    end
  end
end
