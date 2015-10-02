describe Course do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:markdown_description) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:markdown_long_description) }
  it { is_expected.to validate_presence_of(:long_description) }
end
