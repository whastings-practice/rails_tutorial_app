require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_page_title(title) }
  end

  describe "Home page" do

    before { visit root_path }

    it { should have_heading('Rails Tutorial App') }
    it { should_not have_title_tag('Home') }

    describe "for signed-in users" do
      let(:user) { get_test_user }
      before do
        get_test_micropost(user, content: 'Lorem ipsum')
        get_test_micropost(user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      describe "the user's micropost count" do

        describe "for multiple posts" do
          let(:count) { user.microposts.count }

          it "should show plural count" do
            should have_selector('aside span', text: "#{count} microposts")
          end
        end

        describe "for one post" do
          before do
            user.microposts.delete_all
            get_test_micropost(user, content: 'Foobar')
            visit root_path
          end

          it "should show a singular count" do
            should have_selector('aside span', text: '1 micropost')
          end
        end

        describe "for no posts" do
          before do
            user.microposts.delete_all
            visit root_path
          end

          it "should show a zero count" do
            should have_selector('aside span', text: '0 microposts')
          end
        end
      end

      it "should render the user's feed" do
        user.feed.paginate(page: 1).each do |item|
          should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { get_test_user }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link('0 following', href: following_user_path(user)) }
        it { should have_link('1 followers', href: followers_user_path(user)) }
      end
    end

  end

  describe "Help page" do

    before { visit help_path }
    let(:title) { 'Help' }

    it_should_behave_like "all static pages"

  end

  describe "About page" do

    before { visit about_path }
    let(:title) { 'About Us' }

    it_should_behave_like "all static pages"

  end

  describe "Contact page" do

    before { visit contact_path }
    let(:title) { 'Contact' }

    it_should_behave_like "all static pages"

  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "Sign in"
    should have_page_title('Sign in')
    click_link "About"
    should have_page_title('About Us')
    click_link "Help"
    should have_page_title('Help')
    click_link "Contact"
    should have_page_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    should have_page_title('Sign up')
  end

end
