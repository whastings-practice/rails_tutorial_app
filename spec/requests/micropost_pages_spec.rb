require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { get_test_user }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button 'Post' }

        it { should have_error_message('error') }
      end
    end
  end

  describe "micropost destruction" do
    before { get_test_micropost(user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end

end
