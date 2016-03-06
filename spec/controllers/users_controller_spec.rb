describe UsersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  context "when no proper access to actions is given" do
    [[:index, :get], [:show, :get], [:add_user_role, :post],
      [:remove_user_role, :post]].each do |action_name, action_verb|
      describe "##{ action_name }" do
        before do
          if action_name == :index
            @action_params = {}
          else
            @action_params = { id: user.id }
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

        context "with logged in teacher user" do
          before do
            sign_in teacher_user
            send(action_verb, action_name, @action_params)
          end

          it { is_expected.to respond_with(:found) }
          it { is_expected.to redirect_to(root_path) }
        end
      end
    end
  end

  context "when logged in admin user who has access to actions" do
    before do
      sign_in admin_user
    end

    describe "#index" do
      before do
        get :index
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#show" do
      before do
        get :show, id: user.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#add_user_role" do
      before do
        get :add_user_role, id: user.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(users_path) }
    end

    describe "#remove_user_role" do
      before do
        post :remove_user_role, id: user.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(users_path) }
    end
  end
end
