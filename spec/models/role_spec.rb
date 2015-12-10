describe Role do
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:role_type) }

  it { is_expected.to belong_to(:user) }
end
