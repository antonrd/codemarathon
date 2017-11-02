describe ClassroomsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:classroom) { FactoryGirl.create(:classroom) }
  let(:section) { FactoryGirl.create(:section, course: classroom.course) }
  let(:lesson) { FactoryGirl.create(:lesson, section: section) }
  let(:lesson2) { FactoryGirl.create(:lesson, section: section) }
  let(:task) { FactoryGirl.create(:task) }
  let(:quiz) { FactoryGirl.create(:quiz) }

  let(:classroom_admin) { FactoryGirl.create(:user) }
  let(:classroom_student) { FactoryGirl.create(:user) }

  before do
    user.confirm
    classroom_admin.confirm
    classroom_student.confirm

    classroom.add_admin(classroom_admin)
    classroom.add_student(classroom_student)

    lesson.tasks << task
    lesson2.quizzes << quiz
  end

  describe "#index" do
    before do
      get :index
    end

    it { is_expected.to respond_with(:found) }
    it { is_expected.to redirect_to(courses_path) }
  end

  describe "#show" do
    context "with a non-public course" do
      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :show, params: {id: classroom.slug + "a"}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end

    context "with a public course" do
      before do
        classroom.course.update_attributes(public: true)
      end

      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :show, params: {id: classroom.slug + "a"}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end

      context "with not logged in user" do
        before do
          get :show, params: {id: classroom.slug}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(lesson_classroom_path(classroom, lesson_id: lesson.id)) }
      end
    end
  end

  describe "#lesson" do
    context "with a non-public course" do
      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid lesson" do
        before do
          sign_in classroom_student
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id + 1000}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end

    context "with a public course" do
      before do
        classroom.course.update_attributes(public: true)
      end

      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :lesson, params: {id: classroom.slug + "a", lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with not logged in user" do
        before do
          get :lesson, params: {id: classroom.slug, lesson_id: lesson.id}
        end

        it { is_expected.to respond_with(:success) }
      end
    end
  end

  2.times do |index|
    context "with a #{ index == 0 ? 'non-public' : 'public' } course" do
      before do
        classroom.course.update_attributes(public: index == 1)
      end

      [:lesson_task, :task_solution, :task_successful_runs, :task_runs].each do |action_name|
        describe "##{ action_name }" do
          context "with enrolled logged in user" do
            before do
              sign_in classroom_student
              get action_name, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id }
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with enrolled logged in user and invalid task" do
            before do
              sign_in classroom_student
              get action_name, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id + 1000 }
            end

            it { is_expected.to respond_with(:not_found) }
          end

          context "with logged in classroom admin user" do
            before do
              sign_in classroom_admin
              get action_name, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id }
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with logged in but not enrolled user" do
            before do
              sign_in user
              get action_name, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id }
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(root_path) }
          end

          context "with not logged in user" do
            before do
              get action_name, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id }
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(new_user_session_path) }
          end
        end
      end
    end
  end

  2.times do |index|
    let(:task_run) { FactoryGirl.create(:task_run, task: task, user: classroom_student) }

    context "with a #{ index == 0 ? 'non-public' : 'public' } course" do
      before do
        classroom.course.update_attributes(public: index == 1)
      end

      describe "#task_run" do
        context "with enrolled logged in user" do
          before do
            sign_in classroom_student
            get :task_run, xhr: true, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                          task_run_id: task_run.id}
          end

          it { is_expected.to respond_with(:success) }
        end

        context "with enrolled logged in user and invalid task" do
          before do
            sign_in classroom_student
            get :task_run, xhr: true, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id + 1000,
                          task_run_id: task_run.id}
          end

          it { is_expected.to respond_with(:not_found) }
        end

        context "with logged in classroom admin user" do
          before do
            sign_in classroom_admin
            get :task_run, xhr: true, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                          task_run_id: task_run.id}
          end

          it { is_expected.to respond_with(:unprocessable_entity) }
        end

        context "with logged in but not enrolled user" do
          before do
            sign_in user
            get :task_run, xhr: true, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                          task_run_id: task_run.id}
          end

          it { is_expected.to respond_with(:found) }
          it { is_expected.to redirect_to(root_path) }
        end

        context "with not logged in user" do
          before do
            get :task_run, xhr: true, params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                          task_run_id: task_run.id}
          end

          it { is_expected.to respond_with(:unauthorized) }
        end
      end
    end
  end

  2.times do |index|
    context "with a #{ index == 0 ? 'non-public' : 'public' } course" do
      before do
        classroom.course.update_attributes(public: index == 1)
      end

      [:lesson_quiz, :attempt_quiz].each do |action_name|
        describe "##{ action_name }" do
          context "with enrolled logged in user" do
            before do
              sign_in classroom_student
              get action_name, params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with enrolled logged in user and invalid quiz" do
            before do
              sign_in classroom_student
              get action_name, params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id + 1000}
            end

            it { is_expected.to respond_with(:not_found) }
          end

          context "with logged in classroom admin user" do
            before do
              sign_in classroom_admin
              get action_name, params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with logged in but not enrolled user" do
            before do
              sign_in user
              get action_name, params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(root_path) }
          end

          context "with not logged in user" do
            before do
              get action_name, params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(new_user_session_path) }
          end
        end
      end
    end
  end

  describe '#lesson_task' do
    context "with enrolled logged in user, with task run ID" do
      let(:task_run) { FactoryGirl.create(:task_run, task: task, user: classroom_student) }

      before do
        sign_in classroom_student
        get('lesson_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  task_run_id: task_run.id})
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user, with invalid task run ID" do
      # Assigned to another user
      let(:task_run) { FactoryGirl.create(:task_run, task: task, user: classroom_admin) }

      before do
        sign_in classroom_student
        get('lesson_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  task_run_id: task_run.id})
      end

      it { is_expected.to respond_with(:success) }

      it "returns an alert note about invalid task run ID" do
        expect(flash[:alert]).to eq("Invalid task run was specified")
      end
    end
  end

  ['student_task_runs', 'student_progress'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        before do
          sign_in classroom_student
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      task_id: task.id, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in classroom admin user and invalid user" do
        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      task_id: task.id, user_id: user.id + 100}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      task_id: task.id, user_id: user.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      task_id: task.id, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      task_id: task.id, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  ['update_user_limit', 'activate_user'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        before do
          sign_in classroom_student
          post action_name, params: {id: classroom.slug, user_id: user.id }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      if action_name == 'activate_user'
        context "with logged in classroom admin user and invalid user" do
          before do
            sign_in classroom_admin
            get action_name, params: {id: classroom.slug, user_id: user.id + 100}
          end

          it { is_expected.to respond_with(:not_found) }
        end
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, params: {id: classroom.slug, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, params: {id: classroom.slug, user_id: user.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  describe "#solve_task" do
    let(:solve_task) { double SolveTask }
    let(:solve_task_result) { double 'SolveTaskResult', status: true, message: "SolveTaskResult message" }

    before do
      allow(solve_task).to receive(:call).and_return(solve_task_result)
      allow(SolveTask).to receive(:new).and_return(solve_task)
    end

    context "with enrolled logged in user" do
      before do
        sign_in classroom_student
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(task_runs_classroom_path) }
      it "returns a success message" do
        expect(flash[:notice]).to eq(solve_task_result.message)
      end
    end

    context "with enrolled logged in user and invalid task" do
      before do
        sign_in classroom_student
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id + 1000,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with enrolled logged in user and depleted solving attempts" do
      before do
        FactoryGirl.create_list(:task_run,
          task.task_record_for(classroom_student).runs_limit,
          task: task, user: classroom_student)

        sign_in classroom_student
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_task_classroom_path) }
      it "returns an alert message" do
        expect(flash[:alert]).to eq("No task solving attempts left.")
      end
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(task_runs_classroom_path) }
      it "returns an success message" do
        expect(flash[:notice]).to eq(solve_task_result.message)
      end
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'solve_task', params: {id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
                  lang: 'ruby', source_code: ''}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#attempt_quiz" do
    context "with depleted attempts" do
      before do
        sign_in classroom_student
        FactoryGirl.create_list(:quiz_attempt, quiz.maximum_attempts, quiz: quiz, user: classroom_student)
        get 'attempt_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns an alert message" do
        expect(flash[:alert]).to eq("No more quiz attempts left.")
      end
    end

    context "with not enough time between attempts" do
      before do
        sign_in classroom_student
        quiz.update_attributes(wait_time_seconds: 1000)
        FactoryGirl.create(:quiz_attempt, quiz: quiz, user: classroom_student)
        get 'attempt_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns an alert message" do
        expect(flash[:alert]).to eq("Your last attempt was too soon.")
      end
    end
  end

  describe "#submit_quiz" do
    let(:score_quiz_attempt) { double 'ScoreQuizAttempt' }

    before do
      allow(score_quiz_attempt).to receive(:call)
      allow(ScoreQuizAttempt).to receive(:new).and_return(score_quiz_attempt)
    end

    context "with enrolled logged in user" do
      before do
        sign_in classroom_student
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns a success message" do
        expect(flash[:notice]).to eq("Quiz submitted successfully. Check your result below.")
      end
    end

    context "with enrolled logged in user and invalid quiz" do
      before do
        sign_in classroom_student
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id + 1000}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with enrolled logged in user and depleted submission attempts" do
      before do
        FactoryGirl.create_list(:quiz_attempt, quiz.maximum_attempts,
          quiz: quiz, user: classroom_student)

        sign_in classroom_student
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns an alert message" do
        expect(flash[:alert]).to eq("No more quiz attempts left.")
      end
    end

    context "with enrolled logged in user and not enough time between attempts" do
      before do
        FactoryGirl.create(:quiz_attempt, quiz: quiz, user: classroom_student)
        quiz.update_attributes(wait_time_seconds: 1000)

        sign_in classroom_student
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns an alert message" do
        expect(flash[:alert]).to eq("Your last attempt was too soon.")
      end
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_quiz_classroom_path) }
      it "returns an success message" do
        expect(flash[:notice]).to eq("Quiz submitted successfully. Check your result below.")
      end
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'submit_quiz', params: {id: classroom.slug, lesson_id: lesson2.id, quiz_id: quiz.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  ['student_quiz_attempts', 'student_quiz_attempt'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          sign_in classroom_student
          get action_name, params: {id: classroom.slug, lesson_id: lesson.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id, quiz_attempt_id: quiz_attempt.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in classroom admin user and invalid user" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, lesson_id: lesson2.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id + 100, quiz_attempt_id: quiz_attempt.id}
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user and invalid quiz attempt" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, lesson_id: lesson2.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id, quiz_attempt_id: quiz_attempt.id + 1000}
        end

        if action_name == 'student_quiz_attempt'
          it { is_expected.to respond_with(:not_found) }
        end
      end

      context "with logged in classroom admin user" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, lesson_id: lesson2.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id, quiz_attempt_id: quiz_attempt.id}
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          sign_in user
          get action_name, params: {id: classroom.slug, lesson_id: lesson2.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id, quiz_attempt_id: quiz_attempt.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

        before do
          get action_name, params: {id: classroom.slug, lesson_id: lesson2.id,
                      quiz_id: quiz.id, user_id: quiz_attempt.user.id, quiz_attempt_id: quiz_attempt.id}
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  2.times do |index|
    context "with a #{ index == 0 ? 'non-public' : 'public' } course" do
      before do
        classroom.course.update_attributes(public: index == 1)
      end

      describe "#show_quiz_attempt" do
        context "with enrolled logged in user" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz,
            user: classroom_student) }

          before do
            sign_in classroom_student
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id, quiz_attempt_id: quiz_attempt.id}
          end

          it { is_expected.to respond_with(:success) }
        end

        context "with enrolled logged in user and invalid quiz" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz,
            user: classroom_student) }

          before do
            sign_in classroom_student
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id + 1000, quiz_attempt_id: quiz_attempt.id}
          end

          it { is_expected.to respond_with(:not_found) }
        end

        context "with enrolled logged in user and invalid quiz attempt" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz,
            user: classroom_student) }

          before do
            sign_in classroom_student
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id, quiz_attempt_id: quiz_attempt.id + 1000}
          end

          it { is_expected.to respond_with(:not_found) }
        end

        context "with logged in classroom admin user" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz,
            user: classroom_admin) }

          before do
            sign_in classroom_admin
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id, quiz_attempt_id: quiz_attempt.id}
          end

          it { is_expected.to respond_with(:success) }
        end

        context "with logged in but not enrolled user" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz,
            user: user) }

          before do
            sign_in user
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id, quiz_attempt_id: quiz_attempt.id}
          end

          it { is_expected.to respond_with(:found) }
          it { is_expected.to redirect_to(root_path) }
        end

        context "with not logged in user" do
          let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }

          before do
            get :show_quiz_attempt, params: {id: classroom.slug, lesson_id: lesson2.id,
                          quiz_id: quiz.id, quiz_attempt_id: quiz_attempt.id}
          end

          it { is_expected.to respond_with(:found) }
          it { is_expected.to redirect_to(new_user_session_path) }
        end
      end
    end
  end

  describe "#enroll" do
    context "with logged in, not enrolled user" do
      before do
        sign_in user
        post 'enroll', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with user limit too low" do
      before do
        classroom.update_attributes(user_limit: 0)
        sign_in user
        post 'enroll', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }

      it "returns an error flash notice" do
        expect(flash[:alert]).to be_present
      end
    end

    context "with logged in, not enrolled user and invalid classroom" do
      before do
        sign_in user
        post 'enroll', params: {id: classroom.slug + "a"}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in, enrolled student" do
      before do
        sign_in classroom_student
        post 'enroll', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with logged in, classroom admin" do
      before do
        sign_in classroom_admin
        post 'enroll', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with not logged in user" do
      before do
        post 'enroll', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#add_waiting" do
    context "with logged in, not enrolled user" do
      before do
        sign_in user
        post 'add_waiting', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with logged in, not enrolled user and invalid classroom" do
      before do
        sign_in user
        post 'add_waiting', params: {id: classroom.slug + "a"}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in, enrolled student" do
      before do
        sign_in classroom_student
        post 'add_waiting', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with logged in, classroom admin" do
      before do
        sign_in classroom_admin
        post 'add_waiting', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with not logged in user" do
      before do
        post 'add_waiting', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#remove_user" do
    context "with enrolled logged in student" do
      before do
        sign_in classroom_student
        post 'remove_user', params: {id: classroom.slug, user_id: classroom_student.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        post 'remove_user', params: {id: classroom.slug + "a", user_id: user.id}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'remove_user', params: {id: classroom.slug, user_id: classroom_student.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(users_classroom_path) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'remove_user', params: {id: classroom.slug, user_id: classroom_student.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'remove_user', params: {id: classroom.slug, user_id: classroom_student.id}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  ['users', 'student_progress'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        before do
          sign_in classroom_student
          get action_name, params: {id: classroom.slug, user_id: classroom_student.id }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get action_name, params: {id: classroom.slug + "a", user_id: user.id }
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, params: {id: classroom.slug, user_id: classroom_student.id }
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, params: {id: classroom.slug, user_id: classroom_student.id }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, params: {id: classroom.slug, user_id: classroom_student.id }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  describe "#progress" do
    context "with enrolled logged in student" do
      before do
        sign_in classroom_student
        get 'progress', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        get 'progress', params: {id: classroom.slug + "a"}
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        get 'progress', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        get 'progress', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        get 'progress', params: {id: classroom.slug}
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

end
