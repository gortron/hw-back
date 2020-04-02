require 'rails_helper'

RSpec.describe CachedSearch, type: :model do
  # Association test
  it { should have_many(:cached_results) }
  it { should have_many(:posts) }
  # Validation tests
  it { should validate_presence_of(:search_string) }
  it { should validate_presence_of(:created_at) }
  it { should validate_presence_of(:updated_at) }
end