user = User.create!(
  email: 'anton@codemarathon.com',
  password: 'testpass',
  password_confirmation: 'testpass',
  confirmed_at: Time.now,
  active: true)

Role.create!(
  user: user,
  role_type: User::ROLE_ADMIN)

Role.create!(
  user: user,
  role_type: User::ROLE_TEACHER)

CreateCourse.new({title: "Basic Algorithms and Data Structures",
  markdown_description: "This course will teach you **the most important algorithms** and **data structures** that you will need in your career as an engineer. After you complete the course you will be ready to tackle some non-trivial algorithmic problems.",
  markdown_long_description: "This course will teach you **the most important algorithms** and **data structures** that you will need in your career as an engineer. After you complete the course you will be ready to tackle some non-trivial algorithmic problems.",
  slug: "basic-algorithms",
  visible: true},
  user).call

py_course = CreateCourse.new({title: "Introduction to Programming with Python",
  markdown_description: "Python is one of the most popular programming languages and is really easy to start with. In this course we will look at some general concepts in programming using Python.",
  markdown_long_description: "Python is one of the most popular programming languages and is really easy to start with. In this course we will look at some general concepts in programming using Python.",
  slug: "intro-programming",
  visible: true},
  user).call

section1 = Section.create!(title: "What is Python?", position: 1, course: py_course, visible: true)
section2 = Section.create!(title: "Main constructs", position: 2, course: py_course, visible: true)
section3 = Section.create!(title: "Classes in Python", position: 3, course: py_course, visible: true)

Lesson.create!(title: "Python 101", position: 1, section: section1, visible: true)
Lesson.create!(title: "Python applications", position: 2, section: section1, visible: true)

Lesson.create!(title: "For loops", position: 1, section: section2, visible: true)
Lesson.create!(title: "If/else statements", position: 2, section: section2, visible: true)
Lesson.create!(title: "Generators", position: 3, section: section2, visible: true)

Lesson.create!(title: "Class basics", position: 1, section: section3, visible: true)
Lesson.create!(title: "Inheritance", position: 2, section: section3, visible: true)
Lesson.create!(title: "Types of methods", position: 3, section: section3, visible: true)
