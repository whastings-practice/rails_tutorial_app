require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "Signin page" do
    before { visit signin_path }

    it { should have_page_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_page_title('Sign in') }
      it { should have_error_message }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      let(:user) { get_test_user }
      before { valid_signin(user) }

      it { should have_page_title(user.name) }
      it { should have_signedin_nav(user) }
      it { should_not have_signedout_nav }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_signedout_nav }
        it { should_not have_signedin_nav(user) }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { get_test_user }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          valid_signin(user)
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            should have_title_tag('Edit user')
          end

          describe "when signing in again" do
            before do
              click_link "Sign out"
              sign_in(user)
            end

            it "should render the default (profile) page" do
              page.should have_page_title(user.name)
            end
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_page_title('Sign in') }
          it { should have_notice('Please sign in.') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }

          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }

          it { should have_page_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_page_title('Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_page_title('Sign in') }
        end

      end

    end

    describe "in the Microposts controller" do

      describe "submitting to the create action" do
        before { post microposts_path }

        specify { response.should redirect_to(signin_path) }
      end

      describe "submitting to the destroy action" do
        before { delete micropost_path(get_test_micropost) }
        specify { response.should redirect_to(signin_path) }
      end

    end

    describe "in the Relationships controller" do

      describe "submitting to the create action" do
        before { post relationships_path }

        specify { response.should redirect_to(signin_path) }
      end

      describe "submitting to the destroy action" do
        before { delete relationship_path(1) }
        specify { response.should redirect_to(signin_path) }
      end

    end

    describe "as wrong user" do
      let(:user) { get_test_user }
      let(:wrong_user) { get_test_user('wrong@example.com') }
      before { sign_in(user, no_capybara: true) }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title_tag('Edit user') }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { get_test_user }
      let(:non_admin) { get_test_user }

      before { sign_in(non_admin, no_capybara: true) }

      describe "submitting a DELETE request to Users#destroy action" do
        before { delete user_path(user) }

        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as signed-in user" do
      before { sign_in(get_test_user) }

      describe "when visiting the sign-up page" do
        before { visit signup_path }

        it { should_not have_page_title('Sign up') }
      end

      describe "submitting a POST request to the Users#create action" do
        before do
          sign_in(get_test_user, no_capybara: true)
          post users_path
        end

        specify { response.should redirect_to(root_path) }
      end
    end

  end

end
