describe OmniauthCallbacksController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  [:google_oauth2, :github, :facebook].each do |provider_name|
    describe "##{ provider_name }" do
      context "with new user" do
        before do
          mock_auth_hash(provider_name)
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider_name]
          get provider_name
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }

        it "returns no flash notices" do
          expect(flash.keys.count).to eq(0)
        end

        it "adds a new user" do
          expect(User.count).to eq(1)
        end
      end

      context "with existing user" do
        let(:user) { FactoryGirl.create(:user) }

        before do
          user.confirm
          mock_auth_hash(provider_name, user.email)
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider_name]
          get provider_name
        end

        it { is_expected.to redirect_to(root_path) }

        it "makes user active" do
          expect(user.reload.active).to be_truthy
        end

        it "returns no flash notices" do
          expect(flash.keys.count).to eq(0)
        end
      end

      context "when there are no left spots for active users" do
        before do
          create_list(:user, Settings.users_limit)
          mock_auth_hash(provider_name)
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider_name]
          get provider_name
        end

        it { is_expected.to redirect_to(new_user_session_path) }

        it "does not add an active user" do
          expect(User.active.count).to eq(Settings.users_limit)
        end

        it "creates an inactive user" do
          expect(User.inactive.count).to eq(1)
        end

        it "returns an error flash notice" do
          expect(flash[:alert]).to be_present
        end
      end

      context "with existing user with an invitation" do
        let(:user) { FactoryGirl.create(:user) }
        let!(:user_invitation) { FactoryGirl.create(:user_invitation, email: user.email) }

        before do
          user.confirm
          mock_auth_hash(provider_name, user.email)
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider_name]
          get provider_name
        end

        it { is_expected.to redirect_to(root_path) }

        it "returns no flash notices" do
          expect(flash.keys.count).to eq(0)
        end

        it "marks user invitation as used" do
          expect(user_invitation.reload.used).to be_truthy
        end
      end
    end
  end
end
