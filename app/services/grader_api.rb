require "net/http"
require "uri"

class GraderApi
  def initialize
    @host = Rails.application.secrets.grader_host
    @email = Rails.application.secrets.grader_email
    @access_token = Rails.application.secrets.grader_token

    Rails.logger.info("Accessing grader at #{host} with user #{email}")
  end

  def add_task(task)
    args = {"email" => @email,
            "task[name]" => task.title,
            "task[description]" => task.description,
            "task[task_type]" => task.task_type,
            }
    args["task[wrapper_code]"] = task.wrapper_code if task.task_type == Task::TASK_TYPE_PYUNIT
    send_post_request('/tasks', args)
  end

  def update_task(task)
    args = {"email" => @email,
            "task[name]" => task.title,
            "task[description]" => task.description,
            "task[task_type]" => task.task_type,
            "task_id" => task.external_key
            }
    args["task[wrapper_code]"] = task.wrapper_code if task.task_type == Task::TASK_TYPE_PYUNIT
    send_post_request("/tasks/#{task.external_key}/update_task", args)
  end

  # def add_task_files(task)
  #   args = {"email" => @email,
  #           "run[task_id]" => task.external_key,
  #           "run[code]" => "update_task",
  #           "run[data]" => task.id.to_s
  #           }
  #   send_post_request('/runs', args)
  # end

  def resubmit_run(task, task_run)
    args = {"email" => @email}
    send_post_request('/runs/' + task_run.external_key + '/resubmit', args)
  end

  def solve_task(task, task_run)
    data_hash = {"source_code" => task_run.source_code,
                 "lang" => task_run.lang
                }
    args = {"email" => @email,
            "run[task_id]" => task.external_key,
            "run[code]" => "run_task",
            "run[data]" => data_hash.to_json,
            "run[max_memory_kb]" => task.memory_limit_kb,
            "run[max_time_ms]" => task.time_limit_ms
            }
    send_post_request('/runs', args)
  end

  def update_checker(task, task_run)
    data_hash = {"source_code" => task_run.source_code,
                 "lang" => task_run.lang
                }
    args = {"email" => @email,
            "run[task_id]" => task.external_key,
            "run[code]" => "update_checker",
            "run[data]" => data_hash.to_json
            }
    send_post_request('/runs', args)
  end

  def get_run_status(task_run)
    args = {"email" => @email}
    send_get_request('/runs/' + task_run.external_key.to_s, args)
  end

protected
  attr_reader :host, :email, :access_token

  def send_get_request(path, args)
    begin
      uri = URI.parse(@host + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5.0
      http.use_ssl = false
      headers = { "Authorization" => "Token token=\"#{@access_token}\"" }
      uri.query = URI.encode_www_form(args)
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      return JSON::parse(response.body)
    rescue
      puts "HTTP Get Exception: " + $!.message
      return {"status" => 1, "message" => "Grader error."}
    end
  end

  def send_post_request(path, args)
    begin
      uri = URI.parse(@host + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5.0
      http.use_ssl = false
      headers = { "Authorization" => "Token token=\"#{@access_token}\"" }
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data(args)
      response = http.request(request)
      return JSON::parse(response.body)
    rescue
      puts "HTTP Post Exception: " + $!.message
      return {"status" => 1, "message" => "Grader error. HTTP Post Exception: " + $!.message}
    rescue
    end
  end
end
