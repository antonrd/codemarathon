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
end
