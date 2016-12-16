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
    [[:index, :get], [:show, :get], [:add_user_role, :post], [:destroy, :delete],
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
        post :add_user_role, id: user.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(user_path(user)) }
      it "returns a success message" do
        expect(flash[:notice]).to be_present
      end
    end

    describe "#remove_user_role" do
      before do
        post :remove_user_role, id: user.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(user_path(user)) }
      it "returns a success message" do
        expect(flash[:notice]).to be_present
      end
    end

    describe "#destroy" do
      before do
        delete :destroy, id: user.id
      end
      it { is_expected.to respond_with(:found)}
      it { is_expected.to redirect_to(users_path)}
      it "returns an success message" do
        expect(flash[:notice]).to eq "User was deleted!"
      end
    end

    describe "#destroy himslef" do
      before do
        delete :destroy, id: admin_user.id
      end
      it { is_expected.to respond_with(:found)}
      it { is_expected.to redirect_to(users_path)}
      it "returns an error message" do
        expect(flash[:alert]).to eq "You can't delete yourself!"
      end
    end
  end

  describe "#edit_profile" do
    context "without logged in user" do
      before do
        get :edit_profile
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in user" do
      before do
        sign_in user
        get :edit_profile
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  describe "#update_profile" do
    context "without logged in user" do
      before do
        post :update_profile, user: { name: user.name }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with logged in user" do
      before do
        sign_in user
        post :update_profile, user: { name: user.name }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(edit_profile_path) }
    end
  end
end
