# root = "/home/grader/applications/grader"
root = "/home/hiredintech/applications/codemarathon"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.codemarathon.sock"
worker_processes 2
timeout 30
