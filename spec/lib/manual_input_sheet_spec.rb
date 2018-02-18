require 'rails_helper'

describe ManualInputSheet do
  let(:session_mock) { instance_double(GoogleDrive::Session) }
  let(:spreadsheet_double) { instance_double(GoogleDrive::Spreadsheet) }
  let(:worksheet_double) { instance_double(GoogleDrive::Worksheet) }
  let(:test_campaign_values) {
    [
      "Alex Graffeo-Cohen",
      "",
      "DNC",
      "Call to Action",
      "This is a call to action",
      "Please, do the thing!",
      "http://google.com",
      "",
      "",
      "Email",
      "",
      "",
      "Senator",
      "US Senate",
      "Richard",
      "Blumenthal",
      "123 Fake Street / Los Angeles, CA 60622",
      "test@example.org",
      "111-111-1111"
    ]
  }
  let(:test_rows) {
    [
      [
        "Inputter Name",
        "identifiers",
        "origin_system",
        "title",
        "description",
        "template",
        "browser_url",
        "featured_image_url",
        "total_outreaches",
        "type",
        "share_url",
        "targets",
        "target.title",
        "target.organization",
        "target.given_name",
        "target.family_name",
        "target.ocdid",
        "postal_addresses",
        "email_addresses",
        "phone_numbers"
      ],
      test_campaign_values
    ]
  }

  before do
    allow(GoogleDrive::Session).
      to receive(:from_service_account_key).
      and_return(session_mock)
    allow(ENV).to receive(:[]) { nil }
    allow(ENV).
      to receive(:[]).
      with("GOOGLE_APPLICATION_CREDENTIALS").
      and_return("credentials")
  end

  describe "#campaign_worksheet_rows" do
    it "returns all rows of campaign worksheet" do
      expect(session_mock).
        to receive(:spreadsheet_by_key).
        with(ManualInputSheet::SHEET_ID).
        and_return(spreadsheet_double)
      expect(spreadsheet_double).
        to receive(:worksheets).
        and_return([worksheet_double])
      expect(worksheet_double).
        to receive(:rows).
        and_return(test_rows)

      subject = ManualInputSheet.new
      subject.load_sheet

      expect(subject.campaign_worksheet_rows).
        to eq(test_rows)
    end
  end

  describe "#advocacy_campaigns" do
    it "returns an advocacy campaign for each row" do
      expect(session_mock).
        to receive(:spreadsheet_by_key).
        with(ManualInputSheet::SHEET_ID).
        and_return(spreadsheet_double)
      expect(spreadsheet_double).
        to receive(:worksheets).
        and_return([worksheet_double])
      expect(worksheet_double).
        to receive(:rows).
        and_return(test_rows)

      subject = ManualInputSheet.new
      subject.load_sheet
      campaigns = subject.advocacy_campaigns

      expect(campaigns.count).to eq(1)

      campaign = campaigns.first

      expect(campaign.title).to eq("Call to Action")
      expect(campaign.description).
        to eq("This is a call to action")
      expect(campaign.action_type).to eq("Email")
    end
  end
end
