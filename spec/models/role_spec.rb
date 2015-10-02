describe Role do
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:role_type) }
end
