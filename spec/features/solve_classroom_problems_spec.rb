feature "Solve classroom problems" do

  given(:user) { FactoryGirl.create :user }
  given(:lesson) { FactoryGirl.create :lesson }
  given(:classroom) { FactoryGirl.create :classroom, course: lesson.section.course }
  given(:task_iofiles) { FactoryGirl.create :task }
  given(:grader_response) do
    {
      "status" => 0,
      "run_id" => 1,
      "message" => "Success"
    }
  end

  background do
    lesson.tasks << task_iofiles

    user.confirmed_at = Time.now
    user.save

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    classroom.add_student(user)

    visit lesson_task_classroom_path(classroom, lesson, task_iofiles)
  end

  context "when user opens a task for solving" do
    scenario "boilerplate code is loaded for C++ by default", js: true do
      expect(page).to have_css(".ace_content")
      expect(page).to have_css("textarea#source_code", visible: false)
      expect(page.find(:css, 'textarea#source_code', visible: false).value).to eq(
        task_iofiles.cpp_boilerplate)
    end

    scenario "loads boilerplate code for selected language", js: true do
      within('select#lang') do
        select('Java')
      end

      page.find(:css, 'textarea#source_code', visible: false).set "some random text"

      page.find(:css, 'a.load-boilerplate-code').click

      expect(page.find(:css, 'textarea#source_code', visible: false).value).to eq(
        task_iofiles.java_boilerplate)
    end

    scenario "shows no link to load boilerplate code when there is none", js: true do
      within('select#lang') do
        select('Ruby')
      end

      expect(page).not_to have_css('a.load-boilerplate-code')
    end

    scenario "loads the code for the selected language", js: true do
      within('select#lang') do
        select('Java')
      end

      expect(page.find(:css, 'textarea#source_code', visible: false).value).to eq(
        task_iofiles.java_boilerplate)
    end

    scenario "remembers the code written in one language between language changes" do
      java_code = 'some java code'

      within('select#lang') do
        select('Java')
      end

      page.find(:css, 'textarea#source_code', visible: false).set java_code

      within('select#lang') do
        select('Ruby')
      end

      within('select#lang') do
        select('Java')
      end

      expect(page.find(:css, 'textarea#source_code', visible: false).value).to eq(java_code)
    end
  end

  context "when user submits a task" do
    given(:grader_api) { double('GraderApi') }

    scenario "sends the source code to the grader API" do
      expect(grader_api).to receive(:solve_task).with(
        task_iofiles, instance_of(TaskRun)).and_return(grader_response)
      expect(GraderApi).to receive(:new).and_return(grader_api)

      within('select#lang') do
        select('Ruby')
      end

      page.find(:css, 'textarea#source_code', visible: false).set "puts 'Hello World'"

      click_button('Submit solution')
    end
  end
end
