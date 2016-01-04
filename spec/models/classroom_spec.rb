describe Classroom do
  let(:classroom) { FactoryGirl.create(:classroom) }
  let(:user) { FactoryGirl.create(:user) }

  describe "#add_admin" do
    it "makes user an admin in classroom" do
      classroom.add_admin(user)

      classroom_record = classroom.classroom_records.first
      expect(classroom_record.user).to eq(user)
      expect(classroom_record.role.to_sym).to eq(ClassroomRecord::ROLE_ADMIN)
    end
  end
end
