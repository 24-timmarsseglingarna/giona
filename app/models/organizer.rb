class Organizer < ApplicationRecord

  default_scope { order 'name' }
  scope :is_active, -> (boolean = true) { joins(:regattas).where("regattas.active = ?", boolean) }
  scope :has_regatta, ->(r_id) { joins(:regattas).where("regattas.id = ?", r_id) }
  scope :marathon_eligible, -> { where(marathon_eligible: true) }

  has_many :regattas, dependent: :destroy
  has_many :races, :through => :regattas
  has_many :default_starts, dependent: :destroy

  validates_presence_of :name, :email_from, :name_from
  validates_uniqueness_of :name, :external_id
  validates :web_page, url: { allow_nil: true }
  validate :validate_email_from



  # Display name for headings: "Svenska Kryssarklubbens Stockholmskrets"
  # becomes "Stockholmskretsen".
  def short_name
    n = name.sub(/\ASvenska Kryssarklubbens /, '')
    n.sub(/krets\z/, 'kretsen')
  end

  def reset_default_start
     self.defualt_start.delete_all
  end

  private

  def validate_email_from
    if self.email_from.present?
      if ! EmailAddress.valid? self.email_from, host_validation: :syntax
        errors.add(:email_from, "det är något fel med mejladressen")
      end
    end
  end

end
