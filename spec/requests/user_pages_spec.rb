require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do
    let(:user) { get_test_user }

    before(:all) { 30.times { get_test_user } }
    after(:all) { User.delete_all }
    before do
      sign_in user
      visit users_path
    end

    it { should have_page_title('All users') }

    describe "pagination" do

      it { should have_pagination }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          should have_selector('li > a', text: user.name)
        end
      end

    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }

        it "should not be able to delete herself" do
          expect { delete user_path(admin) }.to_not change(User, :count).by(-1)
        end
      end
    end

  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_page_title('Sign up') }
  end

  describe "profile page" do
    let(:user) { get_test_user }

    before do
      31.times { get_test_micropost(user, content: 'Foo') }
      visit user_path(user)
    end

    it { should have_page_title(user.name) }

    describe "microposts" do
      it { should have_content(user.microposts.count) }

      describe "pagination" do
        it { should have_pagination }

        it "should list each micropost" do
          user.microposts.paginate(page: 1).each do |post|
            should have_content(post.content)
          end
        end

      end
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { get_test_user }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button 'Follow'
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button 'Follow'
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button 'Follow' }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button 'Unfollow'
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button 'Unfollow'
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button 'Unfollow' }
          it { should have_selector('input', value: 'Follow') }
        end
      end
    end
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_page_title("Sign up") }
        it { should have_error_message('The form contains') }
        it { should have_error_list }
        it { should_not have_content('Password digest') }
      end
    end

    describe "with valid information" do
      before { valid_signup }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving a user" do
        before { click_button submit }

        let(:user) { User.find_by_email("user@example.com") }

        it { should have_page_title(user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end

  describe "edit" do
    let(:user) { get_test_user }
    before do
      sign_in(user)
      visit edit_user_path(user)
    end

    describe "page" do

      it { should have_heading('Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save change" }

      it { should have_error_message('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before { valid_edit(new_name, new_email, user) }

      it { should have_page_title(new_name) }
      it { should have_link('Sign out', href: signout_path) }
      it { should have_success_message('Profile updated') }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "following/followers" do
    let(:user) { get_test_user }
    let(:other_user) { get_test_user }
    before { user.follow!(other_user) }

    describe "followed users (following)" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title('Following') }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title('Followers') }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end

end
