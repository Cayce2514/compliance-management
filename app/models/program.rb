# A Regulatory Program
#
# The top of the Program -> CO -> Control hierarchy
class Program < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel
  include SearchableModel

  attr_accessible :title, :slug, :company

  before_save :upcase_slug

  validates :title, :slug,
    :presence => { :message => "needs a value" }
  validates :slug,
    :uniqueness => { :message => "must be unique" }

  has_many :sections, :order => :slug
  has_many :controls, :order => :slug

  has_many :cycles

  belongs_to :source_document, :class_name => 'Document'
  belongs_to :source_website, :class_name => 'Document'
  
  is_versioned_ext

  def display_name
    slug
  end
end
