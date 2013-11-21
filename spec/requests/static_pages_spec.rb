require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_page_title(title) }
  end

  describe "Home page" do

    before { visit root_path }

    it { should have_selector('h1', text: 'Rails Tutorial App') }
    it { should_not have_selector('title', text: full_title('Home')) }

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
