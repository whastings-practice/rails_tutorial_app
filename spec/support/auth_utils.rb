RSpec::Matchers.define(:have_signedin_nav) do |user|
  match do |page|
    page.should have_link('Profile', href: user_path(user))
    page.should have_link('Sign out', href: signout_path)
    page.should have_link('Settings', href: edit_user_path(user))
    page.should have_link('Users', href: users_path)
  end
end

RSpec::Matchers.define(:have_signedout_nav) do
  match do |page|
    page.should have_link('Sign in', href: signin_path)
  end
end
