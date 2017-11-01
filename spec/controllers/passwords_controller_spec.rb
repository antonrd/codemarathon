describe PasswordsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  before do
    user.confirm
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "with signed in user" do
    [[:new, :get], [:create, :post], [:edit, :get], [:update, :patch]].each do |action_name, action_verb|
      describe "##{ action_name }" do
        before do
          sign_in user
          send(action_verb, action_name)
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }

        it "returns an error flash notice" do
          expect(flash[:alert]).to be_present
        end
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

    describe "#create" do
      context "with not confirmed user" do
        before do
          post :create, params: { user: { email: user2.email  } }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with confirmed user" do
        before do
          post :create, params: { user: { email: user.email  } }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid user" do
        before do
          post :create, params: { user: { email: "random@email.com"  } }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end
    end

    describe "#edit" do
      before do
        user.send_reset_password_instructions

        get :edit, params: { reset_password_token: user.reset_password_token }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#update" do
      context "with not confirmed user" do
        before do
          reset_token = user2.send_reset_password_instructions

          put :update, params: { user: { reset_password_token: reset_token,
            password: "testpass", password_confirmation: "testpass" } }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with confirmed user" do
        before do
          reset_token = user.send_reset_password_instructions

          put :update, params: { user: { reset_password_token: reset_token,
            password: "testpass", password_confirmation: "testpass" } }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(new_user_session_path) }

        it "returns a successful flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid reset password token" do
        before do
          patch :update, params: { user: { reset_password_token: "invalid_token",
            password: "testpass", password_confirmation: "testpass" } }
        end

        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
