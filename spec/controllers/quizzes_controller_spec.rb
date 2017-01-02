describe QuizzesController do
  let(:quiz) { FactoryGirl.create(:quiz) }
  let(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz) }
  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  let!(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz: quiz, user: user) }

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  context "when no proper access to actions is given" do
    [[:index, :get], [:show, :get], [:new, :get], [:create, :post],
      [:edit, :get], [:update, :patch], [:destroy, :delete],
      [:attempt, :get], [:submit, :post], [:show_attempt, :get],
      [:all_attempts, :get]].each do |action_name, action_verb|
      describe "##{ action_name }" do
        before do
          if [:index, :all_attempts].include?(action_name)
            @action_params = {}
          else
            @action_params = { id: quiz.id }
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

        context "with logged in admin user" do
          before do
            sign_in admin_user
            send(action_verb, action_name, @action_params)
          end

          it { is_expected.to respond_with(:found) }
          it { is_expected.to redirect_to(root_path) }
        end
      end
    end
  end

  context "when logged in teacher user who has access to actions" do
    before do
      sign_in teacher_user
    end

    describe "#index" do
      before do
        get :index
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#show" do
      before do
        get :show, id: quiz.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#new" do
      before do
        get :new
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#create" do
      before do
        post :create, quiz: FactoryGirl.attributes_for(:quiz)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(quiz_path(Quiz.last)) }
    end

    describe "#edit" do
      before do
        get :edit, id: quiz.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#update" do
      before do
        patch :update, id: quiz.id, quiz: FactoryGirl.attributes_for(:quiz)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(quiz_path(quiz)) }
    end

    describe "#destroy" do
      before do
        delete :destroy, id: quiz.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(quizzes_path) }
    end

    describe "#attempt" do
      before do
        get :attempt, id: quiz.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#submit" do
      before do
        post :submit, generate_quiz_answers(quiz.quiz_questions).merge(id: quiz.id)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(quiz_path(quiz)) }
    end

    describe "#show_attempt" do
      before do
        get :show_attempt, id: quiz.id, quiz_attempt_id: quiz_attempt.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#all_attempts" do
      before do
        get :all_attempts
      end

      it { is_expected.to respond_with(:success) }
    end
  end
end
