require 'spec_helper'

RSpec.describe IdentityDocAuth::LexisNexis::ErrorGenerator do

  let(:exception_notifier) { instance_double('Proc') }

  let(:config) do
    IdentityDocAuth::LexisNexis::Config.new(
      exception_notifier: exception_notifier,
    )
  end

  def build_error_info(doc_result: nil, liveness_result: nil, passed: [], failed: [])
    {
      ConversationId: 31000406181234,
      Reference: 'Reference1',
      LivenessChecking: 'test',
      ProductType: 'TrueID',
      TransactionReasonCode: 'testing',
      DocAuthResult: doc_result,
      Alerts: {
        passed: passed,
        failed: failed,
      },
      AlertFailureCount: failed.length,
      PortraitMatchResults: { FaceMatchResult: liveness_result },
      ImageMetrics: {},
    }
  end

  context 'The correct errors are delivered with liveness off when' do
    it 'DocAuthResult is Attention' do
      error_info = build_error_info(
        doc_result: 'Attention',
        failed: [{ name: '2D Barcode Read', result: 'Attention' }]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:back)
      expect(output[:back]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::BARCODE_READ_CHECK,
      )
    end

    it 'DocAuthResult is Failed' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [{ name: 'Visible Pattern', result: 'Failed' }]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:id)
      expect(output[:id]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::ID_NOT_VERIFIED,
      )
    end

    it 'DocAuthResult is Failed with multiple different alerts' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [
          {name: '2D Barcode Read', result: 'Attention'},
          {name: 'Visible Pattern', result: 'Failed'},
        ]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:general)
      expect(output[:general]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::GENERAL_ERROR_NO_LIVENESS,
      )
    end

    it 'DocAuthResult is Failed with multiple id alerts' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [
          {name: 'Expiration Date Valid', result: 'Attention'},
          {name: 'Full Name Crosscheck', result: 'Failed'},
        ]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:id)
      expect(output[:id]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::GENERAL_ERROR_NO_LIVENESS,
      )
    end

    it 'DocAuthResult is Failed with multiple back alerts' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [
          {name: '2D Barcode Read', result: 'Attention'},
          {name: '2D Barcode Content', result: 'Failed'},
        ]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:back)
      expect(output[:back]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::MULTIPLE_BACK_ID_FAILURES,
      )
    end

    it 'DocAuthResult is Failed with an unknown alert' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [{ name: 'Not a known alert', result: 'Failed' }]
      )

      expect(exception_notifier).to receive(:call).
        with(anything, hash_including(:response_info)).twice

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:general)
      expect(output[:general]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::GENERAL_ERROR_NO_LIVENESS,
      )
    end

    it 'DocAuthResult is Failed with multiple alerts including an unknown' do
      error_info = build_error_info(
        doc_result: 'Failed',
        failed: [
          { name: 'Not a known alert', result: 'Failed' },
          { name: 'Birth Date Crosscheck', result: 'Failed' },
        ]
      )

      expect(exception_notifier).to receive(:call).
        with(anything, hash_including(:response_info)).once

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:id)
      expect(output[:id]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::BIRTH_DATE_CHECKS,
      )
    end

    it 'DocAuthResult is Failed with an unknown passed alert' do
      error_info = build_error_info(
        doc_result: 'Failed',
        passed: [{ name: 'Not a known alert', result: 'Passed' }],
        failed: [{ name: 'Birth Date Crosscheck', result: 'Failed' }],
      )

      expect(exception_notifier).to receive(:call).
        with(anything, hash_including(:response_info)).once

      output = described_class.new(config).generate_trueid_errors(error_info, false)

      expect(output.keys).to contain_exactly(:id)
      expect(output[:id]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::BIRTH_DATE_CHECKS,
      )
    end
  end

  context 'The correct errors are delivered with liveness on when' do
    it 'DocAuthResult is Attention and selfie has passed' do
      error_info = build_error_info(
        doc_result: 'Attention',
        liveness_result: 'Pass',
        failed: [{ name: '2D Barcode Read', result: 'Attention' }]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, true)

      expect(output.keys).to contain_exactly(:back)
      expect(output[:back]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::BARCODE_READ_CHECK,
      )
    end

    it 'DocAuthResult is Attention and selfie has failed' do
      error_info = build_error_info(
        doc_result: 'Attention',
        liveness_result: 'Fail',
        failed: [{ name: '2D Barcode Read', result: 'Attention' }]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, true)

      expect(output.keys).to contain_exactly(:general)
      expect(output[:general]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::GENERAL_ERROR_LIVENESS,
      )
    end

    it 'DocAuthResult is Attention and selfie has succeeded' do
      error_info = build_error_info(
        doc_result: 'Attention',
        liveness_result: 'Pass',
        failed: [{ name: '2D Barcode Read', result: 'Attention' }]
      )

      output = described_class.new(config).generate_trueid_errors(error_info, true)

      expect(output.keys).to contain_exactly(:back)
      expect(output[:back]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::BARCODE_READ_CHECK,
      )
    end

    it 'DocAuthResult has passed but liveness failed' do
      error_info = build_error_info(doc_result: 'Passed', liveness_result: 'Fail')

      output = described_class.new(config).generate_trueid_errors(error_info, true)

      expect(output.keys).to contain_exactly(:selfie)
      expect(output[:selfie]).to contain_exactly(
        IdentityDocAuth::LexisNexis::Errors::SELFIE_FAILURE,
      )
    end
  end
end
