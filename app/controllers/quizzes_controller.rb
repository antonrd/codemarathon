class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher_role

  def index
    @quizzes = Quiz.all
  end

  def show
    quiz
  end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.create(quiz_params.merge(creator_id: current_user.id))

    if @quiz.persisted?
      redirect_to quiz_path(@quiz), notice: "Quiz created successfully"
    else
      flash[:alert] = "Failed to create new quiz. Errors: #{ @quiz.errors.full_messages.join(". ") }"
      render 'new'
    end
  end

  def edit
    quiz
  end

  def update
    if quiz.update_attributes(quiz_params)
      redirect_to quiz_path(quiz), notice: "Quiz updated successfully"
    else
      flash[:alert] = "Failed to update quiz. Errors: #{ quiz.errors.full_messages.join(". ") }"
      render 'edit'
    end
  end

  def destroy
    quiz.destroy

    redirect_to quizzes_path, notice: "Quiz was deleted successfully"
  end

  def attempt
    quiz
  end

  def submit
    ScoreQuizAttempt.new(quiz, current_user, params).call

    redirect_to quiz_path(quiz)
  end

  def show_attempt
    @quiz_attempt = quiz.quiz_attempts.find(params[:quiz_attempt_id])
    @attempt_answers = @quiz_attempt.deserialize_answers
  end

  def all_attempts
    @quiz_attempts = QuizAttempt.latest_first.page(params[:page]).per(100)
  end

  protected

  def quiz
    @quiz ||= Quiz.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(:title, :maximum_attempts, :wait_time_seconds,
      quiz_questions_attributes: [:id, :content, :question_type,
        :freetext_regex, :explanation, :_destroy,
          quiz_answers_attributes: [:id, :content, :correct, :_destroy]])
  end
end
