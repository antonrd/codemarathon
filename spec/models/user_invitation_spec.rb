describe UserInvitation do
  let!(:user_invitation) { FactoryGirl.create(:user_invitation) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
end
