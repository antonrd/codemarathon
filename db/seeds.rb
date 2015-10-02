User.create!(
  email: 'anton@codemarathon.com',
  password: 'testpass',
  password_confirmation: 'testpass',
  confirmed_at: Time.now)

Course.create!(
  title: "Basic Algorithms and Data Structures",
  markdown_description: "This course will teach you **the most important algorithms** and **data structures** that you will need in your career as an engineer. After you complete the course you will be ready to tackle some non-trivial algorithmic problems.",
  markdown_long_description: "This course will teach you **the most important algorithms** and **data structures** that you will need in your career as an engineer. After you complete the course you will be ready to tackle some non-trivial algorithmic problems."
)

Course.create!(
  title: "Introduction to Programming with Python",
  markdown_description: "Python is one of the most popular programming languages and is really easy to start with. In this course we will look at some general concepts in programming using Python.",
  markdown_long_description: "Python is one of the most popular programming languages and is really easy to start with. In this course we will look at some general concepts in programming using Python."
)
