# This will not work if an application with a dependency e.g. cowboy is
# declared in 'applications' tuple in the application file. 
erl -pa ./ebin/ ./deps/*/ebin -eval "application:start(soil)" -config soil -detached
