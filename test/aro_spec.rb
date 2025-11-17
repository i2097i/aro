require_relative :rspec_helper.to_s

describe Aro do
  before :all do
    puts "before all"
  end

  after :all do
    puts "after all"
  end

  it 'should puts' do
    expect(true).to be_truthy
    puts(:should)
  end
end