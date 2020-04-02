require 'rails_helper'

# Test suite for the Todo model
RSpec.describe CachedResult, type: :model do
  # Association test
  # ensure Todo model has a 1:m relationship with the Item model
  it { should belong_to(:post) }
  it { should belong_to(:cached_search) }
  # Validation tests
  # ensure columns title and created_by are present before saving
  it { should validate_presence_of(:post_id) }
  it { should validate_presence_of(:cached_search_id) }
  it { should validate_presence_of(:created_at) }
  it { should validate_presence_of(:updated_at) }
end