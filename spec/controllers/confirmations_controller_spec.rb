describe ConfirmationsController, focus: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  before do
    user.confirm
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "with signed in user" do
    [[:new, :get], [:show, :get], [:create, :post]].each do |action_name, action_verb|
      describe "##{ action_name }" do
        before do
          sign_in user
          send(action_verb, action_name)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }
      end
    end
  end

  context "without signed in user" do
    describe "#new" do
      before do
        get :new
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#show" do
      context "with valid confirmation token" do
        before do
          get :show, confirmation_token: user2.confirmation_token
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid confirmation token" do
        before do
          get :show, confirmation_token: user.confirmation_token
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns an error flash notice" do
          expect(flash[:alert]).to be_present
        end
      end
    end

    describe "#create" do
      context "with not confirmed user" do
        before do
          post :create, user: { email: user2.email }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with confirmed user" do
        before do
          post :create, user: { email: user.email }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid user" do
        before do
          post :create, user: { email: "random@email.com" }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end
    end
  end
end
