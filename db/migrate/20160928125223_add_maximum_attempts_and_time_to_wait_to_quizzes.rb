class AddMaximumAttemptsAndTimeToWaitToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :maximum_attempts, :integer
    add_column :quizzes, :wait_time_seconds, :integer
  end
end
