feature "Classroom main page" do

  given(:user) { FactoryGirl.create :user }
  given(:user2) { FactoryGirl.create :user }
  given(:classroom) { FactoryGirl.create :classroom }

  context "when user not logged in" do
    context "when classroom's user limit is reached" do
      background do
        classroom.add_student(user)
        classroom.update_attributes(user_limit: 1)
        visit course_path(classroom.course)
      end

      scenario "shows no free spots message" do
        within ".call-to-action" do
          expect(page).to have_link 'Sign up to the waiting list'
          expect(page).to have_text 'All spots in this course are currently taken'
        end
      end
    end

    context "when classroom has free spots left" do
      background do
        classroom.update_attributes(user_limit: 1)
        visit course_path(classroom.course)
      end

      scenario "shows free spots message" do
        within ".call-to-action" do
          expect(page).to have_link 'Log in to enroll in classroom'
          expect(page).to have_text '1 spot left in classroom'
        end
      end
    end

    context "when classroom has no user limit" do
      background do
        classroom.update_attributes(user_limit: nil)
        visit course_path(classroom.course)
      end

      scenario "shows no message" do
        expect(page).to have_link 'Log in to enroll in classroom'
        expect(page).not_to have_css '.cta-explanation'
      end
    end

    context "when classroom's user limit is set to 0" do
      background do
        classroom.update_attributes(user_limit: 0)
        visit course_path(classroom.course)
      end

      scenario "shows no message" do
        expect(page).to have_link 'Sign up to the waiting list'
        expect(page).to have_text 'This course is currently under development'
      end
    end

    context "when the classroom course is public" do
      background do
        classroom.course.update_attributes(public: true)
        visit course_path(classroom.course)
      end

      scenario "allows visitors to just look at the course" do
        expect(page).to have_link('Just take a look')
      end
    end
  end

  context "when user is logged in" do
    before do
      user.confirm
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
    end

    context "when user is not enrolled" do
      context "when classroom's user limit is reached" do
        background do
          classroom.add_student(user2)
          classroom.update_attributes(user_limit: 1)
          visit course_path(classroom.course)
        end

        scenario "shows no free spots message" do
          within ".call-to-action" do
            expect(page).to have_link 'Sign up to the waiting list'
            expect(page).to have_text 'All spots in this course are currently taken'
          end
        end
      end

      context "when classroom has free spots left" do
        background do
          classroom.update_attributes(user_limit: 1)
          visit course_path(classroom.course)
        end

        scenario "shows free spots message" do
          within ".call-to-action" do
            expect(page).to have_link 'Enroll in classroom'
            expect(page).to have_text '1 spot left in classroom'
          end
        end
      end

      context "when classroom's user limit is set to 0" do
        background do
          classroom.update_attributes(user_limit: 0)
          visit course_path(classroom.course)
        end

        scenario "shows no message" do
          expect(page).to have_link 'Sign up to the waiting list'
          expect(page).to have_text 'This course is currently under development'
        end
      end

      context "when the classroom course is public" do
        background do
          classroom.course.update_attributes(public: true)
          visit course_path(classroom.course)
        end

        scenario "allows visitors to just look at the course" do
          expect(page).to have_link('Just take a look')
        end
      end
    end

    context "when user is enrolled" do
      background do
        classroom.add_student(user)
      end

      context "when classroom's user limit is reached" do
        background do
          classroom.update_attributes(user_limit: 0)
          visit course_path(classroom.course)
        end

        scenario "allows user to enter classroom" do
          within ".call-to-action" do
            expect(page).to have_link 'Go to classroom'
          end
        end
      end

      context "when classroom has free spots left" do
        background do
          classroom.update_attributes(user_limit: 1)
          visit course_path(classroom.course)
        end

        scenario "allows user to enter classroom" do
          within ".call-to-action" do
            expect(page).to have_link 'Go to classroom'
          end
        end
      end

      context "when the classroom course is public" do
        background do
          classroom.course.update_attributes(public: true)
          visit course_path(classroom.course)
        end

        scenario "does not show the link for just looking at the course" do
          expect(page).not_to have_link('Just take a look')
        end
      end
    end

    context "when user is on the waiting list" do
      background do
        classroom.add_student(user, false)
      end

      context "when classroom's user limit is reached" do
        background do
          classroom.update_attributes(user_limit: 0)
          visit course_path(classroom.course)
        end

        scenario "tells user they are on the waiting list" do
          within ".call-to-action" do
            expect(page).to have_text 'You are on the waiting list for this classroom.'
          end
        end
      end

      context "when classroom has free spots left" do
        background do
          classroom.update_attributes(user_limit: 1)
          visit course_path(classroom.course)
        end

        scenario "allows user to enroll" do
          within ".call-to-action" do
            expect(page).to have_link 'Enroll in classroom'
            expect(page).to have_text '1 spot left in classroom'
          end
        end
      end

      context "when the classroom course is public" do
        background do
          classroom.course.update_attributes(public: true)
          visit course_path(classroom.course)
        end

        scenario "allows visitors to just look at the course" do
          expect(page).to have_link('Just take a look')
        end
      end
    end
  end
end
