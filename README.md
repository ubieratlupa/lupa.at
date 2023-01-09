# README

## Local Installation Quick Start

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

