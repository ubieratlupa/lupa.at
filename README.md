# Welcome

You are looking at the source code of lupa.at, the website of the Ubi Erat Lupa database.

If you have any questions, feel free to email jakob@eggerapps.at

## Local Installation Quick Start

If you want to work on the Lupa website, the steps below should get you up and running.

```zsh
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ echo 'eval "$(~/.rbenv/bin/rbenv init - zsh)"' >> ~/.zshrc
$ git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
$ rbenv install 3.1.2
$ rbenv local 3.1.2
$ gem install bundler
$ bundle install
$ rails s
```

