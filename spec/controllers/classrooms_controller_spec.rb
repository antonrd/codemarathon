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
    context "with enrolled logged in user" do
      before do
        sign_in classroom_student
        get :show, id: classroom.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        get :show, id: classroom.id + 1
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        get :show, id: classroom.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        get :show, id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        get :show, id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#lesson" do
    context "with enrolled logged in user" do
      before do
        sign_in classroom_student
        get :lesson, id: classroom.id, lesson_id: lesson.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user and invalid lesson" do
      before do
        sign_in classroom_student
        get :lesson, id: classroom.id, lesson_id: lesson.id + 1
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        get :lesson, id: classroom.id, lesson_id: lesson.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        get :lesson, id: classroom.id, lesson_id: lesson.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        get :lesson, id: classroom.id, lesson_id: lesson.id
      end

      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  [:lesson_task, :task_runs].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in user" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.id, lesson_id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with enrolled logged in user and invalid task" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.id, lesson_id: lesson.id, task_id: task.id + 1
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.id, lesson_id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.id, lesson_id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.id, lesson_id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  ['student_task_runs', 'student_progress'].each do |action_name|
    describe "##{ action_name }" do
      context "with enrolled logged in student" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.id, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in classroom admin user and invalid user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.id, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id + 100
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.id, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.id, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.id, lesson_id: lesson.id,
            task_id: task.id, user_id: user.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end
    end
  end

  describe "#solve_task" do
    context "with enrolled logged in user" do
      before do
        sign_in classroom_student
        post 'solve_task', id: classroom.id, lesson_id: lesson.id, task_id: task.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_task_classroom_path) }
    end

    context "with enrolled logged in user and invalid task" do
      before do
        sign_in classroom_student
        post 'solve_task', id: classroom.id, lesson_id: lesson.id, task_id: task.id + 1
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'solve_task', id: classroom.id, lesson_id: lesson.id, task_id: task.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(lesson_task_classroom_path) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'solve_task', id: classroom.id, lesson_id: lesson.id, task_id: task.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'solve_task', id: classroom.id, lesson_id: lesson.id, task_id: task.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#enroll" do
    context "with logged in, not enrolled user" do
      before do
        sign_in user
        post 'enroll', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with logged in, not enrolled user and invalid classroom" do
      before do
        sign_in user
        post 'enroll', id: classroom.id + 1
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in, enrolled student" do
      before do
        sign_in classroom_student
        post 'enroll', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with logged in, classroom admin" do
      before do
        sign_in classroom_admin
        post 'enroll', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(classroom_path) }
    end

    context "with not logged in user" do
      before do
        post 'enroll', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

  describe "#remove_user" do
    context "with enrolled logged in student" do
      before do
        sign_in classroom_student
        post 'remove_user', id: classroom.id, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        post 'remove_user', id: classroom.id + 1, user_id: user.id
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        post 'remove_user', id: classroom.id, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(users_classroom_path) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        post 'remove_user', id: classroom.id, user_id: classroom_student.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        post 'remove_user', id: classroom.id, user_id: classroom_student.id
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
          get action_name, id: classroom.id, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with enrolled logged in user and invalid classroom" do
        before do
          sign_in classroom_student
          get action_name, id: classroom.id + 1, user_id: user.id
        end

        it { is_expected.to respond_with(:not_found) }
      end

      context "with logged in classroom admin user" do
        before do
          sign_in classroom_admin
          get action_name, id: classroom.id, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in but not enrolled user" do
        before do
          sign_in user
          get action_name, id: classroom.id, user_id: classroom_student.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with not logged in user" do
        before do
          get action_name, id: classroom.id, user_id: classroom_student.id
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
        get 'progress', id: classroom.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with enrolled logged in user and invalid classroom" do
      before do
        sign_in classroom_student
        get 'progress', id: classroom.id + 1
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context "with logged in classroom admin user" do
      before do
        sign_in classroom_admin
        get 'progress', id: classroom.id
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in but not enrolled user" do
      before do
        sign_in user
        get 'progress', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with not logged in user" do
      before do
        get 'progress', id: classroom.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end
  end

end
