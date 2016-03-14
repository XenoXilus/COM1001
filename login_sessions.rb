get '/login' do
  session[:logged_in] = false

  erb :access
end

get '/logout' do
  session[:logged_in] = false
  session[:admin] = false

  erb :logout
end

post '/login' do
  if params[:loginPassword] == '123'
    session[:logged_in] = true
    session[:email] = params[:loginEmail]
    if session[:email]== 'admin@ch.com'
      session[:admin] = true
    else
      session[:admin] = false
    end
    redirect '/'
  end
  @error = "Password incorrect"

  erb :login
end



