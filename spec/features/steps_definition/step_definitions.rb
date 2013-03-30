Given(/^a first number (\d+)$/) do |first_number|
  @first_operand = first_number.to_i
end

Given(/^a second number (\d+)$/) do |second_number|
  @second_operand = second_number.to_i
end

When(/^I add them$/) do
  @result = @first_operand + @second_operand
end

When(/^I divide them$/) do
  @result = @first_operand / @second_operand
end

When(/^I multiply them$/) do
  @result = @first_operand * @second_operand
end

When(/^I substract them$/) do
  @result = @first_operand - @second_operand
end

Then(/^I get (\d+)$/) do |expected_result|
  expected_result.to_i.should == @result
end