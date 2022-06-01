# frozen_string_literal: true

category = Category.create!(name: "Ruby初級", docker_image: "ruby:3.0.2", editor_mode: "ace/mode/ruby", command: "ruby", extension: "rb")
content = <<EOS
標準入力である整数が与えられる。
3の倍数のときは`Fizz`
5の倍数のときは`Buzz`
15の倍数のときは`FizzBuzz!`
それ以外のときは数字をそのまま出力するようなプログラムを作ってください!
EOS
model_answer = <<EOS
number = gets.chomp.to_i
if number % 15 == 0
  puts "FizzBuzz!"
elsif number % 3 == 0
  puts "Fizz"
elsif number % 5 == 0
  puts "Buzz"
else
  puts number
end
EOS
challenge = category.challenges.build(title: "FizzBuzz問題", content: content, model_answer: model_answer)
checks = [
  { stdin: "1", stdout: "1" },
  { stdin: "3", stdout: "Fizz" },
  { stdin: "5", stdout: "Buzz" },
  { stdin: "7", stdout: "7" },
  { stdin: "8", stdout: "8" },
  { stdin: "9", stdout: "Fizz" },
  { stdin: "10", stdout: "Buzz" },
  { stdin: "15", stdout: "FizzBuzz!" }
]
checks.each do |check|
  challenge.checks << Check.create(check)
end
challenge.save!
