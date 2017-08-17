class ScrapeFail < ApplicationRecord
  scope :active, -> { where(active: true) }
end
