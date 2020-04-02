require 'rails_helper'

RSpec.describe CachedResult, type: :model do
  # Association test
  it { should belong_to(:post) }
  it { should belong_to(:cached_search) }
  
  # Validation tests
  it { should validate_presence_of(:post_id) }
  it { should validate_presence_of(:cached_search_id) }
end