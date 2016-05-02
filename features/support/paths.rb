module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the login\s?page/
      '/login'
    when /the sign_up\s?page/
      '/sign_up'
    when /the account\s?page/
      '/account'
    when /the instructions\s?page/
      '/instructions'
    when /the offers\s?page/
      '/offers'
    when /the statistics\s?page/
      '/stats'
    when /the customer\s?page/
      '/customer_info'
    when /the menu edit\s?page/
      '/admin_edit_menu'
    when /customer orders/
      '/customer_orders'
    when /blacklist customer/
      '/blacklist_customer'
    when /make admin/
      '/make_admin'
    when /about/
      '/about'
    when /menu/
      '/menu'
    when /orders/
      '/orders'
    when /the admin\s?panel/
      '/admin'
    when /logout/
      '/logout'
    when /search customer (.*)/
      "search_customer?input=#{$1}"
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"

    end
  end
end

World(NavigationHelpers)
