describe SessionsController do
  let(:active_user) { FactoryGirl.create(:user, active: true) }
  let(:inactive_user) { FactoryGirl.create(:user, active: false) }

  before do
    active_user.confirm
    inactive_user.confirm
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#new" do
    before do
      get :new
    end

    it { is_expected.to respond_with(:success) }
  end

  describe "#create" do
    context "with active user" do
      before do
        post :create, params: { user: { email: active_user.email, password: active_user.password  } }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
      it "returns a success flash notice" do
        expect(flash[:notice]).to be_present
      end
    end

    context "with inactive user" do
      before do
        create_list(:user, Settings.users_limit)
        post :create, params: { user: { email: inactive_user.email, password: inactive_user.password  } }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
      it "returns an error flash notice" do
        expect(flash[:alert]).to be_present
      end
    end

    context "with inactive user, which has an invitation" do
      let!(:user_invitation) { FactoryGirl.create(:user_invitation, email: inactive_user.email) }

      before do
        post :create, params: { user: { email: inactive_user.email, password: inactive_user.password  } }
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(root_path) }
      it "returns a success flash notice" do
        expect(flash[:notice]).to be_present
      end

      it "marks user as active" do
        expect(inactive_user.reload.active).to be_truthy
      end

      it "marks the user invitation as used" do
        expect(user_invitation).to be_truthy
      end
    end
  end

  describe "#destroy" do
    before do
      sign_in active_user
      delete :destroy
    end

    it { is_expected.to respond_with(:found) }
    it { is_expected.to redirect_to(root_path) }
    it "returns no flash notice" do
      expect(flash[:notice]).to be_nil
    end
  end
end
