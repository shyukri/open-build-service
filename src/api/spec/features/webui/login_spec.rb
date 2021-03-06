require "browser_helper"

RSpec.feature "Login", :type => :feature, :js => true do
  let!(:user) { create(:confirmed_user, login: "proxy_user") }

  before do
    @before = CONFIG["proxy_auth_mode"]
    # Fake proxy mode
    CONFIG["proxy_auth_mode"] = :on
  end

  after do
    CONFIG["proxy_auth_mode"] = @before
  end

  scenario "should log in a user when the header is set" do
    page.driver.add_header("X_USERNAME", "proxy_user")

    visit search_path
    expect(page).to have_css("#link-to-user-home", text: "proxy_user")
  end

  scenario "should not log in any user when no header is set" do
    visit search_path
    expect(page).to have_content("Log In")
  end

  scenario "should create a new user account if user does not exist in OBS" do
    page.driver.add_header('X_USERNAME', 'new_user')
    page.driver.add_header('X_EMAIL', 'new_user@obs.com')
    page.driver.add_header('X_FIRSTNAME', 'Bob')
    page.driver.add_header('X_LASTNAME', 'Geldof')

    visit search_path

    expect(page).to have_css("#link-to-user-home", text: "new_user")
    user = User.where(login: "new_user", realname: "Bob Geldof", email: "new_user@obs.com")
    expect(user).to exist
  end
end
