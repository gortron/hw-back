require 'rails_helper'

# Test suite for the Todo model
RSpec.describe Post, type: :model do
  # Association test
  # ensure Todo model has a 1:m relationship with the Item model
  it { should have_many(:cached_results) }
  it { should have_many(:cached_searches) }
  # Validation tests
  # ensure columns title and created_by are present before saving
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:author_id) }
  it { should validate_presence_of(:origin_id) }
  it { should validate_presence_of(:likes) }
  it { should validate_presence_of(:popularity) }
  it { should validate_presence_of(:reads) }
  it { should validate_presence_of(:tags) }
  it { should validate_presence_of(:created_at) }
  it { should validate_presence_of(:updated_at) }
end