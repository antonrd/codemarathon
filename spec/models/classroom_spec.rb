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

    it "activates a user if it was not active" do
      classroom.add_admin(user, false)

      classroom_record = classroom.classroom_records.first

      classroom.add_admin(user)
      expect(classroom_record.reload.active).to be_truthy
    end
  end

  describe "#is_admin?" do
    it "recognizes classroom admin users" do
      classroom.classroom_records.create(user: user,
        role: ClassroomRecord::ROLE_ADMIN, active: true)

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

    it "activates a user if it was not active" do
      classroom.add_student(user, false)

      classroom_record = classroom.classroom_records.first

      classroom.add_student(user)
      expect(classroom_record.reload.active).to be_truthy
    end
  end

  describe "#is_student?" do
    it "recognizes classroom students" do
      classroom.classroom_records.create(user: user,
        role: ClassroomRecord::ROLE_STUDENT, active: true)

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
      classroom.classroom_records.create(user: user,
        role: ClassroomRecord::ROLE_STUDENT, active: true)
      classroom.remove_user(user)

      expect(classroom.classroom_records.reload).to be_empty
    end
  end

  describe "#find_task" do
    let(:section) { FactoryGirl.create(:section, course: classroom.course) }
    let(:lesson) { FactoryGirl.create(:lesson, section: section) }
    let(:task) { FactoryGirl.create(:task) }

    it "returns the matching task" do
      lesson.tasks << task

      expect(classroom.find_task(task.id, lesson.id)).to eq(task)
    end

    it "throws an exception if no matching task is found in classroom" do
      lesson.section = nil
      lesson.save

      expect { classroom.find_task(task.id, lesson.id) }.to raise_error(
        ActiveRecord::RecordNotFound)
    end
  end

  describe "#find_quiz" do
    let(:section) { FactoryGirl.create(:section, course: classroom.course) }
    let(:lesson) { FactoryGirl.create(:lesson, section: section) }
    let(:quiz) { FactoryGirl.create(:quiz) }

    it "returns the matching quiz" do
      lesson.quizzes << quiz

      expect(classroom.find_quiz(quiz.id, lesson.id)).to eq(quiz)
    end

    it "throws an exception if no matching quiz is found in classroom" do
      lesson.section = nil
      lesson.save

      expect { classroom.find_quiz(quiz.id, lesson.id) }.to raise_error(
        ActiveRecord::RecordNotFound)
    end
  end

  describe "#spots_left" do
    let(:user) { FactoryGirl.create(:user) }

    context "with enrolled user in the classroom" do
      before do
        classroom.add_student(user)
      end

      it "returns a positive number if there are spots left" do
        classroom.update_attributes(user_limit: 10)
        expect(classroom.spots_left).to eq(9)
      end

      it "returns zero if there are no spots left" do
        classroom.update_attributes(user_limit: 0)

        expect(classroom.spots_left).to eq(0)
      end

      it "returns infinity if there is not user limit" do
        expect(classroom.spots_left).to eq(Float::INFINITY)
      end
    end

    context "with user in the waiting list in the classroom" do
      before do
        classroom.add_student(user, false)
      end

      it "does not count the waiting users in the taken spots" do
        classroom.update_attributes(user_limit: 10)

        expect(classroom.spots_left).to eq(10)
      end
    end
  end

  describe "#is_waiting?" do
    it "returns true for users on the waiting list" do
      classroom.add_student(user, false)

      expect(classroom.is_waiting?(user)).to be_truthy
    end

    it "returns false for users that are enrolled" do
      classroom.add_student(user)

      expect(classroom.is_waiting?(user)).to be_falsey
    end

    it "returns false for users that not present in the classroom" do
      expect(classroom.is_waiting?(user)).to be_falsey
    end
  end

  describe "#update_user_limit" do
    context "when new user limit gives access to new users" do
      before do
        classroom.add_student(user, false)
      end

      it "makes inactive users active" do
        classroom.update_user_limit(10)

        expect(classroom.is_student?(user)).to be_truthy
      end

      it "makes only as many active users as allowed" do
        user2 = FactoryGirl.create(:user)
        classroom.add_student(user2, false)
        classroom.update_user_limit(1)

        expect(classroom.is_student?(user2)).to be_falsey
        expect(classroom.is_waiting?(user2)).to be_truthy
      end
    end
  end

  describe "#activate_user" do
    context "with inactive user in classroom" do
      before do
        classroom.add_student(user, false)
      end

      it "makes the user active" do
        classroom.activate_user(user)

        expect(classroom.classroom_records.exists?(user: user, active: true)).to be_truthy
      end
    end

    context "with user not present in classroom" do
      it "changes nothing" do
        classroom.activate_user(user)

        expect(classroom.classroom_records.exists?(user: user)).to be_falsey
      end
    end
  end
end
