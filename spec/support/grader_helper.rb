module GraderHelper
  def stub_grader_calls
    task_response = { "task_id" => 1, "status" => 0, "message" => "success" }
    stub_request(:any, /http:\/\/grader\/tasks.*/).to_return(status: 200, body: task_response.to_json)

    run_response = { "run_id" => 1, "status" => 0, "message" => "success" }
    stub_request(:any, /http:\/\/grader\/runs.*/).to_return(status: 200, body: run_response.to_json)
  end
end
