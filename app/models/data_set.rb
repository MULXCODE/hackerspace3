class DataSet < ApplicationRecord
  belongs_to :region
  has_one :competition, through: :region

  scope :search, ->(term) { where 'name ILIKE ? OR url ILIKE ? OR description ILIKE ?', "%#{term}%", "%#{term}%", "%#{term}%" }

  validates :name, presence: true

  # Compiles a hash of projects associated with a particular data set URL of
  # the form... { data_set_url : [project_name, ... ]}
  # ENHANCEMENT: Should go elsewhere?
  def self.data_set_project_helper
    data_set_urls = all.pluck(:url)
    team_data_sets = TeamDataSet.where(url: data_set_urls).preload(:current_project)
    url_to_project_names = {}
    data_set_urls.each { |url| url_to_project_names[url] = [] }
    team_data_sets.each do |team_data_set|
      url_to_project_names[team_data_set.url] << team_data_set.current_project.project_name
    end
    url_to_project_names
  end

  require 'csv'

  # Outputs a CSV file of Data Set attributes.
  def self.to_csv(options = {})
    data_set_columns = %w[name url description]
    combined = data_set_columns + ['projects']
    url_to_project_names = data_set_project_helper
    CSV.generate(options) do |csv|
      csv << combined
      all.each do |data_set|
        data_set_values = data_set.attributes.values_at(*data_set_columns)
        csv << (data_set_values + [url_to_project_names[data_set.url]])
      end
    end
  end
end
