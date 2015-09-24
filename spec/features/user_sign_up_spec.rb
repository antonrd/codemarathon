feature "User sign up" do

  given(:user) { FactoryGirl.build :user }

  context "user sign up" do
    background do
      visit new_user_registration_path
    end

    scenario "successful" do
      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        fill_in "Password confirmation", with: user.password
        click_button "Sign up"
      end

      expect(page).to have_text "confirmation link"
    end

    scenario "too short password" do
      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Password", with: "1234567"
        fill_in "Password confirmation", with: "1234567"
        click_button "Sign up"
      end

      expect(page).to have_text "minimum is 8 characters"
    end

    scenario "incorrect email address" do
      within "#new_user" do
        fill_in "Email", with: "incorrect@email"
        fill_in "Password", with: user.password
        fill_in "Password confirmation", with: user.password
        click_button "Sign up"
      end

      expect(page).to have_text "Email is invalid"
    end

    scenario "wrong password confirmation" do
      within "#new_user" do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        fill_in "Password confirmation", with: user.password.reverse
        click_button "Sign up"
      end

      expect(page).to have_text "Password confirmation doesn't match Password"
    end

    scenario "missing password confirmation" do
      within "#new_user" do
        fill_in "Email", with: "incorrect@email"
        fill_in "Password", with: user.password
        click_button "Sign up"
      end

      expect(page).to have_text "Password confirmation doesn't match Password"
    end
  end

end
