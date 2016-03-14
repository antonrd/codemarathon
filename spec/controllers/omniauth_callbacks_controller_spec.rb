describe OmniauthCallbacksController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  [:google_oauth2, :github].each do |provider_name|
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
