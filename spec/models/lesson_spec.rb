describe Lesson do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to validate_presence_of(:section) }
  it { is_expected.to validate_presence_of(:markdown_content) }

  it { is_expected.to belong_to(:section) }
  it { is_expected.to have_many(:lesson_records) }
  it { is_expected.to have_and_belong_to_many(:tasks) }

  let!(:section) { FactoryGirl.create(:section) }
  let!(:lesson1) { FactoryGirl.create(:lesson, section: section, position: 1) }
  let!(:lesson2) { FactoryGirl.create(:lesson, section: section, position: 2) }
  let!(:lesson3) { FactoryGirl.create(:lesson, section: section, position: 3) }

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
end
