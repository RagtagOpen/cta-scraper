class AdvocacyCampaign
  attr_reader :title,
    :description,
    :identifiers,
    :origin_system,
    :browser_url,
    :action_type,
    :featured_image_url,
    :template
  attr_accessor :user_id

  def initialize(title:, description:, identifiers:, origin_system:, browser_url:, action_type:, featured_image_url:, template:)
    @title = title
    @description = description
    @identifiers = identifiers
    @origin_system = origin_system
    @browser_url = browser_url
    @action_type = action_type
    @featured_image_url = featured_image_url
    @template = template
  end

  def create
    CTAAggregatorClient::AdvocacyCampaign.create(attributes)
  end

  def attributes
    {
      title: title,
      description: description,
      identifiers: identifiers,
      origin_system: origin_system,
      browser_url: browser_url,
      action_type: action_type,
      featured_image_url: featured_image_url,
      template: template,
      user_id: user_id
    }
  end
end
