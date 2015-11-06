namespace :runs do
  desc "Update runs statuses"
  task :update_status => :environment do
    api = GraderApi.new

    running = true
    puts "Ready to update statuses"

    last_run_id = -1

    while running do
      ["INT", "TERM"].each do |signal|
        Signal.trap(signal) do
          puts "Stopping..."
          running = false
        end
      end

      found = false
      if run = TaskRun.pending.earliest_updated_first.first
        if last_run_id != run.id && !run.external_key.blank?
          found = true
        end

        if run.external_key.present?
          puts "Inspecting run with ID: %d" % run.id
          last_run_id = run.id
          response = api.get_run_status(run)
          puts "Run status update: %s" % response
          if response["status"] == 0
            if run.run_type == TaskRun::TYPE_RUN_TASK
              if response["run_status"] == TaskRun::STATUS_SUCCESS
                points = compute_points(response["run_message"])
              else
                points = 0.0
              end
              run.status = response["run_status"]
              run.message = response["run_message"]
              run.grader_log = response["run_log"]
              run.points = points
              run.save
            elsif run.run_type == TaskRun::TYPE_UPDATE_CHECKER
              run.update_attributes(status: response["run_status"],
                                    message: response["run_message"],
                                    grader_log: response["run_log"],
                                    points: 0.0)
            else
              run.update_attributes(status: TaskRun::STATUS_ERROR,
                                    message: "Unknown code of task run.")
            end
          else
            puts "Failed to update the status of run %d with external key %d. Error: %s" % \
                  [run.id, run.external_key, response["message"]]
            if response.has_key?("run_message")
              run_message = response["run_message"]
            else
              run_message = "Grader error"
            end
            run.update_attributes(status: TaskRun::STATUS_ERROR,
                                  message: response["run_message"],
                                  grader_log: response["run_log"],
                                  points: 0)
          end
        else
          run.update_attribute(:updated_at, Time.now)
        end
      end

      if !found
        sleep 1
      end
    end
  end
end

def compute_points(status_msg)
  arr = status_msg.split(" ")
  return 0.0 if arr.empty?
  points = arr.count{ |st| st == 'ok' }
  return points * 100.0 / arr.size
end
