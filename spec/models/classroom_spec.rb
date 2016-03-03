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

  describe "#is_admin?" do
    it "recognizes classroom admin users" do
      classroom.classroom_records.create(user: user, role: ClassroomRecord::ROLE_ADMIN)

      expect(classroom.is_admin?(user)).to be_truthy
    end

    it "does not recognize non-admin users" do
      expect(classroom.is_admin?(user)).to be_falsey
    end
  end

  describe "#add_student" do
    it "makes user a student in classroom" do
      classroom.add_student(user)

      classroom_record = classroom.classroom_records.first
      expect(classroom_record.user).to eq(user)
      expect(classroom_record.role.to_sym).to eq(ClassroomRecord::ROLE_STUDENT)
    end
  end

  describe "#is_student?" do
    it "recognizes classroom students" do
      classroom.classroom_records.create(user: user, role: ClassroomRecord::ROLE_STUDENT)

      expect(classroom.is_student?(user)).to be_truthy
    end

    it "does not recognize non-student users" do
      expect(classroom.is_student?(user)).to be_falsey
    end
  end

  describe "#has_access?" do
    it "returns true for admins" do
      classroom.add_admin(user)

      expect(classroom.has_access?(user)).to be_truthy
    end

    it "returns true for student" do
      classroom.add_student(user)

      expect(classroom.has_access?(user)).to be_truthy
    end

    it "returns false for users not part of the classroom" do
      expect(classroom.has_access?(user)).to be_falsey
    end
  end

  describe "#remove_user" do
    it "removes a user from a classroom" do
      classroom.classroom_records.create(user: user, role: ClassroomRecord::ROLE_STUDENT)
      classroom.remove_user(user)

      expect(classroom.classroom_records.reload).to be_empty
    end
  end
end
