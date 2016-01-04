class TaskRun < ActiveRecord::Base
  module Constants
    # TYPE_NEW_TASK = "new_task"
    TYPE_UPDATE_TASK = "update_task"
    TYPE_RUN_TASK = "run_task"
    TYPE_UPDATE_CHECKER = "update_checker"

    STATUS_STARTING = "starting"
    STATUS_PENDING = "pending"
    STATUS_RUNNING = "running"
    STATUS_CE = "compilation error"
    STATUS_ERROR = "unknown error"
    STATUS_GRADER_ERROR = "grader error"
    STATUS_SUCCESS = "finished"
  end

  include Constants

  belongs_to :task
  belongs_to :user

  validates :task, presence: true
  validates :user, presence: true
  validates :lang, presence: true
  validates :status, presence: true
  validates :memory_limit_kb, presence: true
  validates :time_limit_ms, presence: true
  validates :points, presence: true

  scope :pending, -> { where(status: [STATUS_PENDING, STATUS_RUNNING]) }
  scope :valid_runs, -> { where.not(status: [STATUS_ERROR, STATUS_GRADER_ERROR]) }
  scope :earliest_updated_first, -> { order("updated_at asc") }
  scope :latest_updated_first, -> { order("updated_at desc") }
  scope :newest_first, -> { order("created_at desc") }

  def update_from_grader_log
    if grader_log.present?
      # if self.lang == 'c++' || self.lang == 'java'
      #   comp_regex = /==== GRADER ==== Start compiling ====(?<comp_log>.*?)==== GRADER ==== End compiling ====/m
      #   res = comp_regex.match(self.grader_log)
      #   self.compilation_log = res['comp_log'] if !res.nil?
      # elsif self.lang == 'python'
      #   comp_regex = /==== STDERR contents BEGIN ====(?<stderr_log>.*?File \"jailed_code\", line.*?)==== STDERR contents END ====/m
      #   res = comp_regex.match(self.grader_log)
      #   if !res.nil?
      #     stderr_log = res['stderr_log'].gsub(/jailed_code/, "program.py")
      #     self.compilation_log = stderr_log
      #   end
      # end

      max_time = grader_log.scan(/Used time: ([0-9\.]+)/).map { |t| BigDecimal.new(t.first) }.max
      max_memory = grader_log.scan(/Used mem: ([0-9]+)/).map(&:first).map(&:to_i).max

      puts "Setting time #{max_time} and memory #{max_memory} for task_run #{id}"

      self.time_limit_ms = max_time * 1000.0 if max_time.present?
      self.memory_limit_kb = max_memory if max_memory.present?
      save
    end
  end
end
