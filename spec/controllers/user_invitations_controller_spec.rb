describe UserInvitationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  context "when no proper access to actions is given" do
    [[:index, :get], [:create, :post], [:update, :patch],
      [:destroy, :delete]].each do |action_name, action_verb|

      before do
        @action_params = {}
        if action_name == :create
          @action_params = { user_invitation: { email: 'some.email@test.com'} }
        elsif action_name == :update
          @action_params = { id: 1, user_invitation: { email: 'some.email@test.com'} }
        elsif action_name == :destroy
          @action_params = { id: 1 }
        end
      end

      describe "##{ action_name }" do
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

    describe "#create" do
      before do
        post :create, user_invitation: { email: 'some.email@test.com' }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(user_invitations_path) }
      it "returns a success message" do
        expect(flash[:notice]).to be_present
      end
    end

    describe "#update" do
      let(:user_invitation) { FactoryGirl.create(:user_invitation) }

      before do
        patch :update, id: user_invitation.id, user_invitation: { email: 'some.email@test.com' }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(user_invitations_path) }
      it "returns a success message" do
        expect(flash[:notice]).to be_present
      end
    end

    describe "#destroy" do
      let(:user_invitation) { FactoryGirl.create(:user_invitation) }

      before do
        delete :destroy, id: user_invitation.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(user_invitations_path) }
      it "returns a success message" do
        expect(flash[:notice]).to be_present
      end
    end
  end
end
