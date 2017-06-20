describe FetchTaskStatistics do
  describe "#fetch_successful_runs_stats" do
    let!(:task) { FactoryGirl.create(:task) }
    let!(:task_run1) { FactoryGirl.create(:task_run, points: 0, lang: 'cpp', task: task) }
    let!(:task_run2) { FactoryGirl.create(:task_run, points: 100, lang: 'cpp', task: task) }
    let!(:task_run3) { FactoryGirl.create(:task_run, points: 100, lang: 'java', task: task) }
    let!(:task_run4) { FactoryGirl.create(:task_run, points: 0, lang: 'python', task: task) }

    subject { FetchTaskStatistics.new.call }

    it "computes total statistics" do
      expect(subject[task.id][:successful_runs]).to eq(2)
      expect(subject[task.id][:all_runs]).to eq(4)
      expect(subject[task.id][:success_percent]).to eq(50)
    end

    context "with a given langauge" do
      it "computes 100\% success when all submissions are successful" do
        expect(subject[task.id][:java_success_percent]).to eq(100)
      end

      it "computes partial success when there are failed submissions" do
        expect(subject[task.id][:cpp_success_percent]).to eq(50)
      end

      it "computes 0 percent success when there are no successful submissions" do
        expect(subject[task.id][:python_success_percent]).to eq(0)
      end

      it "contains no data if there are no submissions for a language" do
        expect(subject[task.id][:ruby_success_percent]).to be_nil
      end
    end
  end
end
