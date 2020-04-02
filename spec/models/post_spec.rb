require 'rails_helper'

RSpec.describe Post, type: :model do
  # Association test
  it { should have_many(:cached_results) }
  it { should have_many(:cached_searches) }
  
  # Validation tests
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:author_id) }
  it { should validate_presence_of(:origin_id) }
  it { should validate_presence_of(:likes) }
  it { should validate_presence_of(:popularity) }
  it { should validate_presence_of(:reads) }
  it { should validate_presence_of(:tags) }
  
end
