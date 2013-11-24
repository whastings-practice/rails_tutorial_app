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

      it { should have_selector('div.pagination') }

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
      end
    end

  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_page_title('Sign up') }
  end

  describe "profile page" do
    let(:user) { get_test_user }

    before { visit user_path(user) }

    it { should have_page_title(user.name) }
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

end
