describe Section do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to validate_presence_of(:course) }

  it { is_expected.to belong_to(:course) }
  it { is_expected.to have_many(:lessons) }

  let!(:course) { FactoryGirl.create(:course) }
  let!(:section1) { FactoryGirl.create(:section, course: course, position: 1) }
  let!(:section2) { FactoryGirl.create(:section, course: course, position: 2) }
  let!(:section3) { FactoryGirl.create(:section, course: course, position: 3) }

  describe "#is_first?" do
    it "returns true for the first section in course" do
      expect(section1.is_first?).to be_truthy
    end

    it "returns false for all sections that are not first in course" do
      expect(section2.is_first?).to be_falsey
    end
  end

  describe "#is_last?" do
    it "returns true for the last section in course" do
      expect(section3.is_last?).to be_truthy
    end

    it "returns false for all sections that are not first in course" do
      expect(section2.is_last?).to be_falsey
    end
  end

  describe "#move_up" do
    it "moves the section to an earlier position" do
      section3.move_up

      expect(section3.is_last?).not_to be_truthy
      expect(section2.is_last?).to be_truthy
    end

    it "doesn't move the first section to an earlier position" do
      section1.move_up

      expect(section1.is_first?).to be_truthy
    end
  end

  describe "#move_down" do
    it "moves the section to a later position" do
      section1.move_down

      expect(section1.is_first?).not_to be_truthy
      expect(section2.is_first?).to be_truthy
    end

    it "doesn't move the last section to a later position" do
      section3.move_down

      expect(section3.is_last?).to be_truthy
    end
  end

  describe "#last_lesson_position" do
    let(:section) { FactoryGirl.create(:section) }
    let!(:lesson1) { FactoryGirl.create(:lesson, section: section, position: 1000) }
    let!(:lesson2) { FactoryGirl.create(:lesson, section: section, position: 1001) }
    let!(:lesson3) { FactoryGirl.create(:lesson, section: section, position: 1002) }

    it "returns the position of the last lesson in the section" do
      expect(section.last_lesson_position).to eq(1002)
    end
  end

  describe "#lessons_visible_for" do
    let(:section) { FactoryGirl.create(:section) }
    let!(:lesson1) { FactoryGirl.create(:lesson, visible: false, section: section) }
    let!(:lesson2) { FactoryGirl.create(:lesson, visible: true, section: section) }
    let!(:lesson3) { FactoryGirl.create(:lesson, visible: false, section: section) }

    context "with teacher user" do
      let(:user) { FactoryGirl.create(:user, :teacher) }

      it "returns all lessons in the section including invisible ones" do
        expect(section.lessons_visible_for(user).count).to eq(3)
      end
    end

    context "with non-teacher user" do
      let(:user) { FactoryGirl.create(:user) }

      it "returns only visible lessons in the section" do
        expect(section.lessons_visible_for(user).count).to eq(1)
      end

      it "returns no lessons if no visible ones exist" do
        lesson2.update_attributes(visible: false)
        expect(section.lessons_visible_for(user).count).to eq(0)
      end
    end
  end

  describe "#first_visible_lesson" do
    let!(:section) { FactoryGirl.create(:section) }
    let!(:lesson) { FactoryGirl.create(:lesson, visible: false, section: section) }

    context "with teacher user" do
      let(:user) { FactoryGirl.create(:user, :teacher) }

      it "returns the very first lesson in the section even if invisible" do
        expect(section.first_visible_lesson(user)).to eq(lesson)
      end
    end

    context "with non-teacher user" do
      let(:user) { FactoryGirl.create(:user) }

      it "returns the first visible lesson in the course" do
        lesson2 = FactoryGirl.create(:lesson, visible: true, section: section)
        expect(section.first_visible_lesson(user)).to eq(lesson2)
      end

      it "returns no lesson if no visible lessons exist" do
        expect(section.first_visible_lesson(user)).to be_nil
      end
    end
  end
end
