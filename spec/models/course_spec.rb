describe Course do
  it { is_expected.to have_many(:sections) }
  it { is_expected.to have_many(:classrooms) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:markdown_description) }
  it { is_expected.to validate_presence_of(:markdown_long_description) }

  describe ".main" do
    context "with main course" do
      let!(:c1) { FactoryGirl.create(:course, visible: true, is_main: false) }
      let!(:c2) { FactoryGirl.create(:course, visible: true, is_main: true) }
      let!(:c3) { FactoryGirl.create(:course, visible: false, is_main: false) }

      it "returns a main course" do
        expect(Course.main.first).to eq(c2)
      end
    end

    context "without main course" do
      let!(:c1) { FactoryGirl.create(:course, visible: false, is_main: false) }
      let!(:c2) { FactoryGirl.create(:course, visible: false, is_main: false) }

      it "returns no main course" do
        expect(Course.main.first).to be_nil
      end
    end
  end

  describe ".visible_for" do
    before do
      FactoryGirl.create(:course, visible: true)
      FactoryGirl.create(:course, visible: true)
      FactoryGirl.create(:course, visible: false)
    end

    it "returns all courses for teachers" do
      user = FactoryGirl.create(:user, :teacher)
      expect(Course.visible_for(user).count).to eq(3)
    end

    it "returns only visible courses for non-teachers" do
      user = FactoryGirl.create(:user)
      expect(Course.visible_for(user).count).to eq(2)
    end
  end

  describe "#last_section_position" do
    let(:course) { FactoryGirl.create(:course) }
    let!(:section1) { FactoryGirl.create(:section, course: course, position: 1000) }
    let!(:section2) { FactoryGirl.create(:section, course: course, position: 1001) }
    let!(:section3) { FactoryGirl.create(:section, course: course, position: 1002) }

    it "returns the position of the last section in the course" do
      expect(course.last_section_position).to eq(1002)
    end
  end

  describe "#first_visible_lesson" do
    let(:course) { FactoryGirl.create(:course) }
    let!(:section) { FactoryGirl.create(:section, course: course) }
    let!(:lesson) { FactoryGirl.create(:lesson, visible: false, section: section) }

    context "with teacher user" do
      let(:user) { FactoryGirl.create(:user, :teacher) }

      it "returns the very first lesson in the course even if invisible" do
        expect(course.first_visible_lesson(user)).to eq(lesson)
      end

      it "returns the first lesson of the first section, which has lessons" do
        section.update_attributes(position: 2)
        FactoryGirl.create(:section, course: course, position: 1)

        expect(course.first_visible_lesson(user)).to eq(lesson)
      end
    end

    context "with non-teacher user" do
      let(:user) { FactoryGirl.create(:user) }

      it "returns the first visible lesson in the course" do
        lesson2 = FactoryGirl.create(:lesson, visible: true, section: section)
        expect(course.first_visible_lesson(user)).to eq(lesson2)
      end

      it "returns no lesson if no visible lessons exist" do
        expect(course.first_visible_lesson(user)).to be_nil
      end
    end
  end

  describe "#sections_visible_for" do
    let(:course) { FactoryGirl.create(:course) }
    let!(:section1) { FactoryGirl.create(:section, visible: false, course: course) }
    let!(:section2) { FactoryGirl.create(:section, visible: true, course: course) }
    let!(:section3) { FactoryGirl.create(:section, visible: false, course: course) }

    context "with teacher user" do
      let(:user) { FactoryGirl.create(:user, :teacher) }

      it "returns all sections in the course including invisible ones" do
        expect(course.sections_visible_for(user).count).to eq(3)
      end
    end

    context "with non-teacher user" do
      let(:user) { FactoryGirl.create(:user) }

      it "returns only visible sections in the course" do
        expect(course.sections_visible_for(user).count).to eq(1)
      end

      it "returns no sections if no visible ones exist" do
        section2.update_attributes(visible: false)
        expect(course.sections_visible_for(user).count).to eq(0)
      end
    end
  end
end
