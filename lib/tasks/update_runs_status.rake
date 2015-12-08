namespace :runs do
  desc "Update runs statuses"
  task :update_status => :environment do
    api = GraderApi.new

    running = true
    puts "Ready to update statuses"

    last_run_id = nil

    while running do
      ["INT", "TERM"].each do |signal|
        Signal.trap(signal) do
          puts "Stopping..."
          running = false
        end
      end

      found_run = ProcessTaskRun.new(api).call

      sleep 1 unless found_run && found_run.id != last_run_id

      last_run_id = found_run.id if found_run
    end
  end
end

