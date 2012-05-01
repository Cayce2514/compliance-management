# A Regulatory Program
#
# The top of the Program -> CO -> Control hierarchy
class Program < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel

  before_save :upcase_slug

  validates :title, :slug, :presence => true

  has_many :sections, :order => :slug

  belongs_to :source_document, :class_name => 'Document'
  belongs_to :source_website, :class_name => 'Document'
  
  is_versioned_ext

  def display_name
    slug
  end
end
