# Awsm

Awsm is an awesome AWS querying tool. Pun most certainly intended.

## Install from RubyGems

Awsm is available on RubyGems, to install it, all you need to do is:

```
gem install awsm
```

## Install from Source

Awsm is written in Ruby 2.1, so you'll need that to start with, you'll also need the `bundler` gem.

```
[you@host:~]$ git clone https://github.com/mduk/awsm
[you@host:~]$ cd awsm
[you@host:~/awsm]$ bundle install
[you@host:~/awsm]$ gem build awsm.gemspec
[you@host:~/awsm]$ gem install awsm-x.x.x.gem
[you@host:~/awsm]$ awsm
```

## Running Awsm

Awsm requires three enviornment variables to be set in order to work. I use something like this:

	#!/bin/bash

	export AWS_ACCESS_KEY_ID="You do not leak keys on github."
	export AWS_SECRET_ACCESS_KEY="You DO, NOT, LEAK, keys on github!"
	export AWS_REGION="eu-west-1"

	echo -e "\033[1m\033[92mAWS Environment Set.\033[0m"

## Configuring Awsm

Awsm will read configuration from `~/.awsm.rb`. This is just used for the `spin` subcommand for now.
An example `~/.awsm.rb` file is shown below:

```
Awsm::configure do |c|

  c.dns do |c|
    c.hosted_zone '/hostedzone/somethingorother'
  end

  # Default Instance Parameters
  c.spin do |c|
    c.instance_type 't2.micro'
    c.key_name 'my-key'
    c.subnet 'subnet-a0b1c2d3'
    c.security_group 'sg-a0b1c2d3'
    c.tag 'h2g2:contact', 'ford.prefect@megadodo.h2g2'
    c.tag 'h2g2:planet', 'kakrafoon'
  end

  # Preset: mything
  c.spin 'mything' do |c|
    c.image_id 'ami-a0b1c2d3'
    c.security_group 'sg-a1b2c3d4'
    c.tag 'thing:environment', 'dev'
  end

end
```

# Licence

See `LICENCE.txt` file.
