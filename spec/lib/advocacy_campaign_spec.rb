require 'rails_helper'

describe AdvocacyCampaign do
  let(:campaign) {
    AdvocacyCampaign.new(
      title: "test",
      description: "description",
      identifiers: ["id"],
      origin_system: "DMC",
      browser_url: "http://google.com",
      action_type: "email",
      featured_image_url: "http://google.com/image.jpg",
      template: "please help us!"
    )
  }

  describe "#attributes" do
    it "returns a hash of attributes to send to API" do
      campaign.user_id = 1

      expect(campaign.attributes).to include(
        title: "test",
        description: "description",
        identifiers: ["id"],
        origin_system: "DMC",
        browser_url: "http://google.com",
        action_type: "email",
        featured_image_url: "http://google.com/image.jpg",
        template: "please help us!",
        user_id: 1
      )
    end
  end

  describe "#create" do
    it "creates a record with the CTAAggregatorClient" do
      expect(CTAAggregatorClient::AdvocacyCampaign).
        to receive(:create).
        with(campaign.attributes)

      campaign.create
    end
  end
end
