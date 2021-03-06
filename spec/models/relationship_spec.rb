require 'spec_helper'

describe Relationship do

  let(:follower) { get_test_user }
  let(:followed) { get_test_user }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do

    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should == follower }
    its(:followed) { should == followed }
  end

  describe "when followed id not present" do
    before { relationship.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end

end
