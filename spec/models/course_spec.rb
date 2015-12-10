describe Course do
  it { is_expected.to have_many(:sections) }
  it { is_expected.to have_many(:classrooms) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:markdown_description) }
  it { is_expected.to validate_presence_of(:markdown_long_description) }
end
