describe CoursesController do
  let(:course) { FactoryGirl.create(:course) }
  let(:invisible_course) { FactoryGirl.create(:course, visible: false) }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  describe "#index" do
    context "with logged in user" do
      before do
        sign_in user
        get :index
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with not logged in user" do
      before do
        get :index
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  describe "#show" do
    context "with not logged in user and visible course" do
      before do
        get :show, id: course.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with not logged in user and invisible course" do
      before do
        get :show, id: invisible_course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in regular user and visible course" do
      before do
        sign_in user
        get :show, id: course.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in regular user and invisible course" do
      before do
        sign_in user
        get :show, id: invisible_course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user and visible course" do
      before do
        sign_in admin_user
        get :show, id: course.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in admin user and invisible course" do
      before do
        sign_in admin_user
        get :show, id: invisible_course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user and visible course" do
      before do
        sign_in teacher_user
        get :show, id: course.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in teacher user and invisible course" do
      before do
        sign_in teacher_user
        get :show, id: invisible_course.slug
      end

      it { is_expected.to respond_with(:success) }
    end

    context "with logged in teacher user and invalid course" do
      before do
        sign_in teacher_user
        post :show, id: course.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end
  end

  describe "#new" do
    context "with not logged in user" do
      before do
        get :new
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in regular user" do
      before do
        sign_in user
        get :new
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user" do
      before do
        sign_in admin_user
        get :new
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user" do
      before do
        sign_in teacher_user
        get :new
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  describe "#create" do
    context "with not logged in user" do
      before do
        post :create, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in regular user" do
      before do
        sign_in user
        post :create, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user" do
      before do
        sign_in admin_user
        post :create, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user" do
      before do
        sign_in teacher_user
        post :create, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(course_path(Course.last)) }
    end
  end

  [:edit, :edit_structure].each do |action_name|
    describe "##{ action_name }" do
      context "with not logged in user" do
        before do
          get action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end

      context "with logged in regular user" do
        before do
          sign_in user
          get action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in admin user" do
        before do
          sign_in admin_user
          get action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in teacher user" do
        before do
          sign_in teacher_user
          get action_name, id: course.slug
        end

        it { is_expected.to respond_with(:success) }
      end

      context "with logged in teacher user and invalid course" do
        before do
          sign_in teacher_user
          post action_name, id: course.slug + "a"
        end

        it { is_expected.to respond_with(:not_found) }
      end
    end
  end

  describe "#update" do
    context "with not logged in user" do
      before do
        patch :update, id: course.slug, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in regular user" do
      before do
        sign_in user
        patch :update, id: course.slug, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user" do
      before do
        sign_in admin_user
        patch :update, id: course.slug, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user" do
      before do
        sign_in teacher_user
        patch :update, id: course.slug, course: FactoryGirl.attributes_for(:course)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(edit_course_path(Course.last)) }
    end

    context "with logged in teacher user and invalid course" do
      before do
        sign_in teacher_user
        post :update, id: course.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end
  end

  describe "#destroy" do
    context "with not logged in user" do
      before do
        delete :destroy, id: course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in regular user" do
      before do
        sign_in user
        delete :destroy, id: course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in admin user" do
      before do
        sign_in admin_user
        delete :destroy, id: course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user" do
      before do
        sign_in teacher_user
        delete :destroy, id: course.slug
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
    end

    context "with logged in teacher user and invalid course" do
      before do
        sign_in teacher_user
        post :destroy, id: course.slug + "a"
      end

      it { is_expected.to respond_with(:not_found) }
    end
  end

  [:set_main, :unset_main].each do |action_name|
    describe "##{ action_name }" do
      context "with not logged in user" do
        before do
          post action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }
      end

      context "with logged in regular user" do
        before do
          sign_in user
          post action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in admin user" do
        before do
          sign_in admin_user
          post action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end

      context "with logged in teacher user" do
        before do
          sign_in teacher_user
          post action_name, id: course.slug
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(edit_course_path(course)) }
      end

      context "with logged in teacher user and invalid course" do
        before do
          sign_in teacher_user
          post action_name, id: course.slug + "a"
        end

        it { is_expected.to respond_with(:not_found) }
      end
    end
  end
end
