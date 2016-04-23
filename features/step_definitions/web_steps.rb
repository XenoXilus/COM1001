require 'uri'
require 'cgi'
require_relative '../support/paths'
require_relative '../../app'

def findValue value
  @customer_info = SQLite3::Database.new './curry_house.sqlite'
  email = 'alex@gmail.com'
  if value.include? 'myname'
    new_value = @customer_info.get_first_value('SELECT firstName FROM customer WHERE email = ?', email)
  elsif value.include? 'mysurname'
    new_value = @customer_info.get_first_value('SELECT surname FROM customer WHERE email = ?',email)
  elsif value.include? 'mytwitter'
    new_value = @customer_info.get_first_value('SELECT twitterAcc FROM customer WHERE email = ?',email)
  elsif value.include? 'mycc'
    new_value = @customer_info.get_first_value('SELECT cc FROM customer WHERE email = ?',email)
  elsif value.include? 'myaddress'
    new_value = @customer_info.get_first_value('SELECT address FROM customer WHERE email = ?',email)
  elsif value.include? 'mybalance'
    new_value = @customer_info.get_first_value('SELECT balance FROM customer WHERE email = ?',email)
  elsif value.include? 'mynewbalance'
    new_value = @customer_info.get_first_value('SELECT balance FROM customer WHERE email = ?',email)
  end

  return new_value
end

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

Given /^(?:|I )am logged in as (.+)$/ do |access|
  #visit path_to('the login page')
  visit '/login'
  if access.include?'admin'
    fill_in('email_address', :with => 'admin@ch.com')
    fill_in('password', :with => '123456')
  elsif access.include?'customer'
    fill_in('email_address', :with => 'alex@gmail.com')
    fill_in('password', :with => '123456')
  end
  click_button('submit')
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )follow "([^\"]*)"(?: within "([^\"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When /^(?:|I )fill in "([^\"]*)" with "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in "([^\"]*)" for "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When /^(?:|I )fill in the following(?: within "([^\"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

When /^(?:|I )select "([^\"]*)" from "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end

When /^(?:|I )check "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end

When /^(?:|I )uncheck "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

When /^(?:|I )choose "([^\"]*)"(?: within "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

When /^(?:|I )attach the file "([^\"]*)" to "([^\"]*)"(?: within "([^\"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, path)
  end
end

Then /^(?:|I )should see JSON:$/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate(JSON.parse(expected_json))
  actual   = JSON.pretty_generate(JSON.parse(response.body))
  expected.should == actual
end

Then /^(?:|I )should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  if text.include? '?my'
    text = findValue(text)
  end
  if text.equal? 'item x' && !@order_text.nil?
    text = @order_text
  end
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^(?:|I )should see \/([^\/]*)\/(?: within "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  if regexp.include? '?my'
    regexp = findValue(regexp)
  end
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath('//*', :text => regexp)
    else
      assert page.has_xpath?('//*', :text => regexp)
    end
  end
end

Then /^(?:|I )should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/(?: within "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_xpath('//*', :text => regexp)
    else
      assert page.has_no_xpath?('//*', :text => regexp)
    end
  end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field,{:disabled => :all})

    if value.include? '?my'
      value = findValue(value)
    end

    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should not contain "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^\"]*)" checkbox(?: within "([^\"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should == 'checked'
    else
      assert_equal 'checked', field_checked
    end
  end
end

Then /^the "([^\"]*)" checkbox(?: within "([^\"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should_not
      field_checked.should_not == 'checked'
    else
      assert_not_equal 'checked', field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^show me the page$/ do
  save_and_open_page
end

#twitter step definitions
def twitter_db_set_up
  config = {
      :consumer_key => 'aLqE0P5k5kkBAOhtgVFCs5GK0',
      :consumer_secret => 'neLJBgq4uEd3s21hE4lSZEDAP46cJzgkmhqRAxzr3BphBjcC7w',
      :access_token => '248845175-FX1jPuSKmGuUxeS71B5sLGdvttjZ2OO6tk5pSilU',
      :access_token_secret => 'sI7Wgj0yF7bLQGdiPxaPGYUrt928hmCuCiQulrbsXls5v'
  }
  @customer = Twitter::REST::Client.new(config)
  @db = SQLite3::Database.new './curry_house.sqlite'
end

When /a customer orders "([^\"]*)"/ do |order_text|
  $order_text = "item #{Random.rand(10000)}" #try to have unique item numbers to avoid duplicate tweets
  twitter_db_set_up
  @customer.update("@curryhouse02 order #{$order_text}")
end

# When /an unregistered customer orders "([^\"]*)"/ do |order_text|
#   $unrg_order_text = "item #{Random.rand(10000)}" #try to have unique item numbers to avoid duplicate tweets
#   config = {
#       :consumer_key => 'ES1nI4rGsK5TLzfjAgJAOrwyJ',
#       :consumer_secret => 'X0PRqKUjaRgqPBOox0QSmeQUO2j4gmIm6iLql5GAdgjpKgm32j',
#       :access_token => '709679775862951936-5TCWCmdABwZpWNmCOxGZ7nY0xQ9Zqlq',
#       :access_token_secret => 'C3BdvX5EfQw6l64sTNn8kUzdsh764fUQ1Ni7LBfanOFZz'
#   }
#   unrg_customer = Twitter::REST::Client.new(config)
#   unrg_customer.update("@curryhouse02 order #{$order_text}")
# end

When /a customer cancels "([^\"]*)"/ do |text|
  if !$order_text.nil?
    text = $order_text
  end
  twitter_db_set_up
  order_id = @db.get_first_value('SELECT order_id FROM tweets WHERE text LIKE ?', ('%'+text+'%'))
  @customer.update("@curryhouse02 cancel #{order_id}")
end

Then /^(?:|I )I should see "([^\"]*)" in the "([^\"]*)" column$/ do |text,row|
  if row.include? 'item'
    if !$order_text.nil?
      row = $order_text
    end
    order_id = @db.get_first_value('SELECT order_id FROM tweets WHERE text LIKE ?', ('%'+row+'%'))
  else
    order_id = row.to_i
  end

  puts "order_id = #{order_id}"

  with_scope("tr:nth-child(#{order_id+1})") do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end