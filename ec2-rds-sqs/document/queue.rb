require 'aws-sdk-sqs'

queue_name = "task2-sqs"

sqs = Aws::SQS::Client.new(
    region: 'ap-northeast-1'
  )

begin
  queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
rescue Aws::SQS::Errors::NonExistentQueue
  puts "A queue named '#{queue_name}' does not exist."
  exit(false)
end

loop do
  receive_message_result = sqs.receive_message({
    queue_url: queue_url,
    message_attribute_names: ["All"],
    max_number_of_messages: 10,
    wait_time_seconds: 20
  })
  timestamp = Time.new

  receive_message_result.messages.each do |message|
    puts "#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}: #{message.body}"

    sqs.delete_message({
      queue_url: queue_url,
      receipt_handle: message.receipt_handle
    })
  end
end