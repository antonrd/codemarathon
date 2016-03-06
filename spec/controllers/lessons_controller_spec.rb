describe LessonsController do
  let(:course) { FactoryGirl.create(:course) }
  let(:section) { FactoryGirl.create(:section, course: course) }
  let(:lesson) { FactoryGirl.create(:lesson, section: section) }
  let(:task) { FactoryGirl.create(:task) }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  let(:lesson_params) do
    { title: 'Section title', section_id: section.id,
      markdown_content: 'hello', visible: true }
  end

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  [[:create, :post], [:update, :patch], [:destroy, :delete],
      [:move_up, :post], [:move_down, :post]].each do |action_name, action_verb|
    describe "##{ action_name }" do
      before do
        if action_name == :create
          @action_params = { lesson: lesson_params }
        elsif action_name == :update
          @action_params = { id: lesson.id, lesson: lesson_params }
        elsif [:destroy, :move_up, :move_down].include?(action_name)
          @action_params = { id: lesson.id }
        end
      end

      context "with not logged in user" do
        before do
          send(action_verb, action_name, @action_params)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end

      context "with logged in regular user" do
        before do
          sign_in user
          send(action_verb, action_name, @action_params)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in admin user" do
        before do
          sign_in admin_user
          send(action_verb, action_name, @action_params)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in teacher user" do
        before do
          sign_in teacher_user
          send(action_verb, action_name, @action_params)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(edit_structure_course_path(course)) }
      end
    end
  end

  describe "#edit" do
    context "with not logged in user" do
      before do
        get :edit, id: lesson.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in regular user" do
      before do
        sign_in user
        get :edit, id: lesson.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user" do
      before do
        sign_in admin_user
        get :edit, id: lesson.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user" do
      before do
        sign_in teacher_user
        get :edit, id: lesson.id
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  [:attach_task, :detach_task].each do |action_name|
    describe "##{ action_name }" do
      context "with not logged in user" do
        before do
          post action_name, id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end

      context "with logged in regular user" do
        before do
          sign_in user
          post action_name, id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in admin user" do
        before do
          sign_in admin_user
          post action_name, id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in teacher user" do
        before do
          sign_in teacher_user
          post action_name, id: lesson.id, task_id: task.id
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(edit_lesson_path(lesson)) }
      end
    end
  end
end
