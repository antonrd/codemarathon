describe SectionsController do
  let!(:course) { FactoryGirl.create(:course) }
  let!(:section) { FactoryGirl.create(:section, course: course) }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  let(:section_params) do
    { title: 'Section title', course_id: course.id, visible: true }
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
          @action_params = { section: section_params }
        elsif action_name == :update
          @action_params = { id: section.id, section: section_params }
        elsif [:destroy, :move_up, :move_down].include?(action_name)
          @action_params = { id: section.id }
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
end
