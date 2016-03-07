describe RegistrationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  before do
    user.confirm
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "with signed in user" do
    [[:new, :get], [:create, :post]].each do |action_name, action_verb|
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

  context "with not signed in user" do
    describe "#new" do
      before do
        get :new
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#create" do
      context "with valid email" do
        before do
          post :create, user: { email: "a@a.com", password: "testpass",
            password_confirmation: "testpass" }
        end

        it { is_expected.to respond_with(:found) }
        it { is_expected.to redirect_to(root_path) }

        it "returns a success flash notice" do
          expect(flash[:notice]).to be_present
        end
      end

      context "with already used email" do
        before do
          post :create, user: { email: user.email, password: "testpass",
            password_confirmation: "testpass" }
        end

        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:new) }
      end
    end
  end
end
