describe Lesson do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to validate_presence_of(:section) }

  it { is_expected.to belong_to(:section) }
  it { is_expected.to have_many(:lesson_records) }
  it { is_expected.to have_and_belong_to_many(:tasks) }

  let(:user) { FactoryGirl.create(:user) }
  let!(:section) { FactoryGirl.create(:section) }
  let!(:lesson1) { FactoryGirl.create(:lesson, section: section, position: 1) }
  let!(:lesson2) { FactoryGirl.create(:lesson, section: section, position: 2) }
  let!(:lesson3) { FactoryGirl.create(:lesson, section: section, position: 3) }
  let!(:classroom) { FactoryGirl.create(:classroom, course: section.course) }
  let!(:lesson_record) { FactoryGirl.create(:lesson_record, lesson: lesson1, user: user, classroom: classroom) }

  describe "#is_first?" do
    it "returns true for the first lesson in section" do
      expect(lesson1.is_first?).to be_truthy
    end

    it "returns false for all lessons that are not first in section" do
      expect(lesson2.is_first?).to be_falsey
    end
  end

  describe "#is_last?" do
    it "returns true for the last lesson in section" do
      expect(lesson3.is_last?).to be_truthy
    end

    it "returns false for all lessons that are not first in section" do
      expect(lesson2.is_last?).to be_falsey
    end
  end

  describe "#move_up" do
    it "moves the lesson to an earlier position" do
      lesson3.move_up

      expect(lesson3.is_last?).not_to be_truthy
      expect(lesson2.is_last?).to be_truthy
    end

    it "doesn't move the first lesson to an earlier position" do
      lesson1.move_up

      expect(lesson1.is_first?).to be_truthy
    end
  end

  describe "#move_down" do
    it "moves the lesson to a later position" do
      lesson1.move_down

      expect(lesson1.is_first?).not_to be_truthy
      expect(lesson2.is_first?).to be_truthy
    end

    it "doesn't move the last lesson to a later position" do
      lesson3.move_down

      expect(lesson3.is_last?).to be_truthy
    end
  end

  describe "#lesson_record_for" do
    it "finds a matching record if it exists" do
      expect(lesson1.lesson_record_for(classroom, user)).to eq(lesson_record)
    end

    it "create a new record if no matching one exists" do
      expect(lesson2.lesson_record_for(classroom, user)).to be_a LessonRecord
    end
  end

  context "with tasks" do
    before do
      lesson1.tasks << FactoryGirl.create(:task)
      lesson1.tasks << FactoryGirl.create(:task)
    end

    describe "#all_tasks_covered_by?" do
      it "returns false if not all tasks were solved by user" do
        expect(lesson1.all_tasks_covered_by?(user)).to be_falsey
      end

      it "returns true if all tasks in lesson were solved by user" do
        lesson1.tasks.each do |task|
          task.task_records.create(user: user, best_score: 50.0, covered: true)
        end

        expect(lesson1.all_tasks_covered_by?(user)).to be_truthy
      end
    end

    describe "#count_covered_tasks_by" do
      it "returns number of covered tasks" do
        lesson1.tasks.first.task_records.create(user: user, best_score: 50.0, covered: true)

        expect(lesson1.count_covered_tasks_by(user)).to eq(1)
      end
    end

    describe "#covered?" do
      it "returns false if the corresponding lesson record is not marked as covered" do
        expect(lesson2.covered?(classroom, user)).to be_falsey
      end

      it "returns true if the corresponding lesson record is marked as covered" do
        lesson2.lesson_records.create(user: user, covered: true, classroom: classroom)

        expect(lesson2.covered?(classroom, user)).to be_truthy
      end
    end

    describe "#cover_lesson_records_if_lesson_covered" do
      it "does not mark lesson records as covered if lesson is not viewed yet" do
        lesson1.cover_lesson_records_if_lesson_covered user

        expect(lesson_record.covered).to be_falsey
      end

      it "does not mark lesson records as covered if not all tasks are solved yet" do
        lesson_record.update_attributes(views: 1)
        lesson1.cover_lesson_records_if_lesson_covered user

        expect(lesson_record.covered).to be_falsey
      end

      it "marks related lesson records as covered if lesson viewed and all tasks are solved" do
        lesson1.tasks.each do |task|
          task.task_records.create(user: user, best_score: 50.0, covered: true)
        end
        lesson_record.update_attributes(views: 1)
        lesson1.cover_lesson_records_if_lesson_covered user

        expect(lesson_record.reload.covered).to be_truthy
      end
    end
  end
end
