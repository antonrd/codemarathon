feature "User log in" do

  given(:user) { FactoryGirl.create :user }

  context "user log in" do
    background do
      user.confirmed_at = Time.now
      user.save
      visit new_user_session_path
    end

    scenario "successful" do
      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_button "Log in"
      end

      expect(page).to have_text user.name
    end

    scenario "incorrect email" do
      within "#new_user" do
        fill_in "Email", with: user.email.reverse
        fill_in "Password", with: user.password
        click_button "Log in"
      end

      expect(page).to have_text 'Invalid email or password'
    end

    scenario "incorrect password" do
      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.email.reverse
        click_button "Log in"
      end

      expect(page).to have_text 'Invalid email or password'
    end
  end

end
