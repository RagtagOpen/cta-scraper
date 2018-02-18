class ManualInputSheet < GoogleSheet
  SHEET_ID = "16R7F6Y35M4Pe9FkcL51pbIiV-4ZkdXef9uZtVADszWY"
  IDENTIFIERS = 1
  ORIGIN_SYSTEM = 2
  TITLE = 3
  DESCRIPTION = 4
  TEMPLATE = 5
  BROWSER_URL = 6
  FEATURED_IMAGE_URL = 7
  ACTION_TYPE = 9

  def initialize
    super(key: SHEET_ID)
  end

  def campaign_worksheet_rows
    @campaign_worksheet_rows ||= campaign_worksheet.rows
  end

  def advocacy_campaigns
    # We want to preserve the header of the sheet just
    # in case we want to see the whole sheet in an
    # error scenario.
    rows = campaign_worksheet_rows.drop(1)

    rows.map do |campaign|
      AdvocacyCampaign.new(
        title: campaign[TITLE],
        description: campaign[DESCRIPTION],
        identifiers: campaign[IDENTIFIERS],
        origin_system: campaign[ORIGIN_SYSTEM],
        browser_url: campaign[BROWSER_URL],
        action_type: campaign[ACTION_TYPE],
        featured_image_url: campaign[FEATURED_IMAGE_URL],
        template: campaign[TEMPLATE]
      )
    end
  end

  private

  def campaign_worksheet
    sheet.worksheets.first
  end
end
