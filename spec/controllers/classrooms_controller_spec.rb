describe ClassroomsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:classroom) { FactoryGirl.create(:classroom) }
  let(:section) { FactoryGirl.create(:section, course: classroom.course) }
  let(:lesson) { FactoryGirl.create(:lesson, section: section) }
  let(:task) { FactoryGirl.create(:task) }

  let(:classroom_admin) { FactoryGirl.create(:user) }
  let(:classroom_student) { FactoryGirl.create(:user) }

  before do
    user.confirm
    classroom_admin.confirm
    classroom_student.confirm

    classroom.add_admin(classroom_admin)
    classroom.add_student(classroom_student)

    lesson.tasks << task
  end

  describe "#show" do
    context "with a non-public course" do
      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :show, id: classroom.slug + "a"
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get :show, id: classroom.slug
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
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :show, id: classroom.slug + "a"
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with not logged in user" do
        before do
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end
    end
  end

  describe "#lesson" do
    context "with a non-public course" do
      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get :lesson, id: classroom.slug, lesson_id: lesson.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid lesson" do
        before do
          sign_in classroom_student
          get :lesson, id: classroom.slug, lesson_id: lesson.id + 1
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :lesson, id: classroom.slug, lesson_id: lesson.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :lesson, id: classroom.slug, lesson_id: lesson.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get :lesson, id: classroom.slug, lesson_id: lesson.id
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
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get :show, id: classroom.slug + "a"
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get :show, id: classroom.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with not logged in user" do
        before do
          get :show, id: classroom.slug
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

      [:lesson_task, :task_solution, :task_runs].each do |action_name|
        describe "##{ action_name }" do
          context "with enrolled logged in user" do
            before do
              sign_in classroom_student
              get action_name, id: classroom.slug, lesson_id: lesson.id, task_id: task.id
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with enrolled logged in user and invalid task" do
            before do
              sign_in classroom_student
              get action_name, id: classroom.slug, lesson_id: lesson.id, task_id: task.id + 1
            end

            it { is_expected.to respond_with(:not_found) }
          end

          context "with logged in classroom admin user" do
            before do
              sign_in classroom_admin
              get action_name, id: classroom.slug, lesson_id: lesson.id, task_id: task.id
            end

            it { is_expected.to respond_with(:success) }
          end

          context "with logged in but not enrolled user" do
            before do
              sign_in user
              get action_name, id: classroom.slug, lesson_id: lesson.id, task_id: task.id
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(root_path) }
          end

          context "with not logged in user" do
            before do
              get action_name, id: classroom.slug, lesson_id: lesson.id, task_id: task.id
            end

            it { is_expected.to respond_with(:found) }
            it { is_expected.to redirect_to(new_user_session_path) }
          end
        end
      end
    end
  end

  ['student_task_runs', 'student_progress'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.slug, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in classroom admin user and invalid user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.slug, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id + 100
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.slug, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.slug, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.slug, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
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
          post action_name, id: classroom.slug, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      if action_name == 'activate_user'
        context "with logged in classroom admin user and invalid user" do
          before do
            sign_in classroom_admin
            get action_name, id: classroom.slug, user_id: user.id + 100
          end

          it { is_expected.to respond_with(:not_found) }
        end
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.slug, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.slug, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.slug, user_id: user.id
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
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
          lang: 'ruby', source_code: ''
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(task_runs_classroom_path) }
      it "returns an success message" do
        expect(flash[:notice]).to eq(solve_task_result.message)
      end
    end

    context "with enrolled logged in user and invalid task" do
      before do
        sign_in classroom_student
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id + 1,
          lang: 'ruby', source_code: ''
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with enrolled logged in user and depleted solving attempts" do
      before do
        FactoryGirl.create_list(:task_run,
          task.task_record_for(classroom_student).runs_limit,
          task: task, user: classroom_student)

        sign_in classroom_student
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
          lang: 'ruby', source_code: ''
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
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
          lang: 'ruby', source_code: ''
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
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
          lang: 'ruby', source_code: ''
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'solve_task', id: classroom.slug, lesson_id: lesson.id, task_id: task.id,
          lang: 'ruby', source_code: ''
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#enroll" do
    context "with logged in, not enrolled user" do
      before do
        sign_in user
        post 'enroll', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with user limit too low" do
      before do
        classroom.update_attributes(user_limit: 0)
        sign_in user
        post 'enroll', id: classroom.slug
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
        post 'enroll', id: classroom.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in, enrolled student" do
      before do
        sign_in classroom_student
        post 'enroll', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with logged in, classroom admin" do
      before do
        sign_in classroom_admin
        post 'enroll', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with not logged in user" do
      before do
        post 'enroll', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#add_waiting" do
    context "with logged in, not enrolled user" do
      before do
        sign_in user
        post 'add_waiting', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with logged in, not enrolled user and invalid classroom" do
      before do
        sign_in user
        post 'add_waiting', id: classroom.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in, enrolled student" do
      before do
        sign_in classroom_student
        post 'add_waiting', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with logged in, classroom admin" do
      before do
        sign_in classroom_admin
        post 'add_waiting', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(classroom.course)) }
    end

    context "with not logged in user" do
      before do
        post 'add_waiting', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#remove_user" do
    context "with enrolled logged in student" do
      before do
        sign_in classroom_student
        post 'remove_user', id: classroom.slug, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        post 'remove_user', id: classroom.slug + "a", user_id: user.id
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'remove_user', id: classroom.slug, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(users_classroom_path) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'remove_user', id: classroom.slug, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'remove_user', id: classroom.slug, user_id: classroom_student.id
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
          get action_name, id: classroom.slug, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.slug + "a", user_id: user.id
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.slug, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.slug, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.slug, user_id: classroom_student.id
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
        get 'progress', id: classroom.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        get 'progress', id: classroom.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        get 'progress', id: classroom.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        get 'progress', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        get 'progress', id: classroom.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

end
