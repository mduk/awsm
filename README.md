# Awsome

Awsome is an awesome AWS querying tool. Pun most certainly intended.

## Make it go!

Awsome is written in Ruby 2.1, so you'll need that to start with, you'll also need the `bundler` gem.

	[you@host:~]$ git clone https://github.com/mduk/awsome
	[you@host:~]$ cd awsome

Awsome requires four enviornment variables to be set in order to work. I use something like this:

	#!/bin/bash

	export AWS_ACCESS_KEY_ID="You do not leak keys on github."
	export AWS_SECRET_ACCESS_KEY="You DO, NOT, LEAK, keys on github!"
	export AWS_REGION="eu-west-1"
	export AWSOME_HOSTEDZONE="Don't leak this either."

	echo -e "\033[1m\033[92mAWS Environment Set.\033[0m"

Once you have that in place, install dependencies.

	[you@host:~/awsome]$ bundle install

Initialise environment variables.

	[you@host:~/awsome]$ source ./setvars.sh
	AWS Environment Set.

And off you go.

	[you@host:~/awsome]$ bundle exec awsome search -dia beta


# Licence

See `LICENCE.txt` file.
