describe TasksController do
  let(:task) { FactoryGirl.create(:task) }
  let(:task_run) { FactoryGirl.create(:task_run, task: task) }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:teacher_user) { FactoryGirl.create(:user, :teacher) }

  let(:task_params) do
    { title: 'Section title', section_id: section.id,
      markdown_content: 'hello', visible: true }
  end

  before do
    user.confirm
    admin_user.confirm
    teacher_user.confirm
  end

  context "when no proper access to actions is given" do
    [[:index, :get], [:show, :get], [:new, :get], [:create, :post],
      [:edit, :get], [:update, :patch], [:solution, :get], [:update_checker, :post],
      [:destroy, :delete], [:solve, :get], [:do_solve, :post],
      [:resubmit_run, :post], [:runs, :get], [:runs_limits, :get],
      [:all_runs, :get], [:update_runs_limit, :post]].each do |action_name, action_verb|
      describe "##{ action_name }" do
        before do
          if [:index, :all_runs].include?(action_name)
            @action_params = {}
          else
            @action_params = { id: task.id }
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
    let(:grader_response) do
      { "task_id" => task.external_key, "status" => 0, "message" => "success" }
    end

    before do
      stub_grader_calls
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
        get :show, id: task.id
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
        post :create, task: FactoryGirl.attributes_for(:task)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(task_path(Task.last)) }
    end

    describe "#edit" do
      before do
        get :edit, id: task.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#update" do
      before do
        patch :update, id: task.id, task: FactoryGirl.attributes_for(:task)
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(task_path(task)) }
    end

    describe "#solution" do
      before do
        get :solution, id: task.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#update_checker" do
      before do
        post :update_checker, id: task.id, source_code: "print hello", lang: "python"
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(edit_task_path(task)) }
    end

    describe "#destroy" do
      before do
        delete :destroy, id: task.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(tasks_path) }
    end

    describe "#solve" do
      before do
        get :solve, id: task.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#do_solve" do
      before do
        post :do_solve, id: task.id, source_code: "print hello", lang: "python"
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(solve_task_path(task)) }
    end

    describe "#resubmit_run" do
      before do
        post :resubmit_run, id: task.id, task_run_id: task_run.id
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(runs_task_path(task)) }
    end

    describe "#runs" do
      before do
        get :runs, id: task.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#run_limits" do
      before do
        get :runs_limits, id: task.id
      end

      it { is_expected.to respond_with(:success) }
    end

    describe "#update_runs_limit" do
      before do
        post :update_runs_limit, id: task.id, user_id: user.id,
          new_runs_limit: 10
      end

      it { is_expected.to respond_with(:found) }
      it { is_expected.to redirect_to(runs_limits_task_path(task)) }

      it "updates the runs limit for the user for the given task" do
        expect(task.task_record_for(user).runs_limit).to eq(10)
      end
    end

  end
end
