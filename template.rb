### .gitignore ###
GITIGNORE_IO_URL = 'https://www.gitignore.io/api/'.freeze

IGNORES = %w(
  ruby
  rails
  sublimetext
  vim
  jetbrains
  linux
  osx
  windows
).freeze

run "curl -s #{GITIGNORE_IO_URL + IGNORES.join('%2C')} > .gitignore"

### Gemfile ###
remove_file 'Gemfile.lock'
create_file 'Gemfile', <<~CODE, force: true
  source 'https://rubygems.org'

  gem 'rails'                 # A full-stack web framework optimized for programmer happiness and sustainable productivity
  gem 'rails-api'             # Rails for API only applications
  gem 'pg'                    # The Ruby interface to the PostgreSQL RDBMS
  gem 'unicorn'               # Rack HTTP server for fast clients and Unix
  gem 'unicorn-worker-killer' # Automatically restart Unicorn workers

  ### API ###
  gem 'active_model_serializers' # ActiveModel::Serializer implementation and Rails hooks
  gem 'versionist'               # A plugin for versioning Rails based RESTful APIs
  gem 'oj'                       # A fast JSON parser and Object marshaller as a Ruby gem
  gem 'json-jwt'                 # JSON Web Token and its family
  gem 'rack-json_schema'         # JSON Schema based Rack middlewares
  gem 'kaminari'                 # A Scope & Engine based, clean, powerful, customizable and sophisticated paginator

  ### Model ###
  gem 'squeel'            # Active Record queries with fewer strings, and more Ruby
  gem 'aasm'              # State machines for Ruby classes
  gem 'enumerize'         # Enumerated attributes with I18n and ActiveRecord/Mongoid support
  gem 'default_value_for' # Provides a way to specify default values for ActiveRecord models
  gem 'active_type'       # Make any Ruby object quack like ActiveRecord
  gem 'seed-fu'           # Advanced seed data handling for Rails

  ### Setting ###
  gem 'config'       # Easiest way to add multi-environment yaml settings
  gem 'dotenv-rails' # Loads environment variables from '.env'
  gem 'rails-i18n'   # Central point to collect locale data for use in Ruby on Rails

  ### CLI ###
  gem 'thor'       # A toolkit for building powerful command-line interfaces
  gem 'formatador' # STDOUT text formatting
  gem 'whenever'   # Provides a clear syntax for writing and deploying cron jobs

  ### Monitoring ###
  gem 'chrono_logger'          # A lock-free logger with timebased file rotation
  gem 'exception_notification' # Exception Notifier Plugin for Rails
  gem 'slack-notifier'         # A simple wrapper for posting to slack channels

  group :development, :test do
    ### Console ###
    gem 'pry-rails'     # An IRB alternative and runtime developer console
    gem 'pry-coolline'  # Live syntax-highlighting for the Pry REPL
    gem 'hirb'          # A mini view framework for console/irb
    gem 'hirb-unicode'  # Unicode support for hirb
    gem 'awesome_print' # Pretty print your Ruby objects with style
    gem 'pry-byebug'    # Pry navigation commands via byebug
    gem 'pry-doc'       # Provide MRI Core documentation and source code for the Pry REPL

    ### Command ###
    gem 'spring'                  # Rails application preloader
    gem 'spring-commands-rspec'   # Implements the rspec command for Spring
    gem 'spring-commands-rubocop' # Implements rubocop command for Spring

    ### Testing ###
    gem 'rspec-rails'        # A testing framework for Rails 3.x and 4.x
    gem 'factory_girl_rails' # A fixtures replacement
  end

  group :test do
    gem 'timecop'           # Making it dead simple to test time-dependent code
    gem 'database_rewinder' # Minimalist's tiny and ultra-fast database cleaner
    gem 'fuubar'            # The instafailing RSpec progress bar formatter
    gem 'simplecov'         # A code coverage analysis tool for Ruby
  end

  group :development do
    ### Analysis ###
    gem 'brakeman'             # A static analysis security vulnerability scanner
    gem 'bullet'               # Help to kill N+1 queries and unused eager loading
    gem 'rubocop'              # A Ruby static code analyzer
    gem 'rails_best_practices' # A code metric tool for rails projects
    gem 'reek'                 # Code smell detector for Ruby
    gem 'flay'                 # Analyzes code for structural similarities
    gem 'fasterer'             # Make your Rubies go faster with this command line tool

    ### Utility ###
    gem 'annotate'           # Annotate Rails classes with schema and routes info
    gem 'migration_comments' # Comments for your migrations
    gem 'rails-erd'          # Generate Entity-Relationship Diagrams for Rails applications
    gem 'prmd'               # JSON Schema tools and doc generation for HTTP APIs
    gem 'jdoc'               # Generate API documentation from JSON Schema
    gem 'quiet_assets'       # Mutes assets pipeline log messages
    gem 'terminal-notifier'  # Send User Notifications on Mac OS X 10.8 from the command-line

    ### Deployment ###
    gem 'capistrano'               # Remote multi-server automation tool
    gem 'capistrano-rbenv'         # Idiomatic rbenv support for Capistrano
    gem 'capistrano-bundler'       # Bundler specific tasks for Capistrano
    gem 'capistrano-rails'         # Official Ruby on Rails specific tasks for Capistrano
    gem 'capistrano3-unicorn'      # Integrates Unicorn tasks into capistrano deployment scripts
    gem 'capistrano-rails-console' # Capistrano plugin which adds a remote rails console
    gem 'slackistrano'             # Slack integration for Capistrano deployments
  end
CODE

### bundle install ###
Bundler.with_clean_env do
  run 'bundle'
end

### README.md ###
create_file 'README.md', "# #{app_name}"
remove_file 'README.rdoc'

### config/environments ###
inside 'config/environments' do
  run 'ln -s production.rb edge.rb'
  run 'ln -s production.rb staging.rb'
end

### config/locales ###
create_file 'config/locales/en.yml', force: true
create_file 'config/locales/ja.yml'

### config/application.rb ###
application do
  <<-CODE.lstrip
    ### TimeZone ###
    config.time_zone                      = 'Tokyo'
    config.active_record.default_timezone = :local

    ### Locale ###
    config.i18n.default_locale = :ja
  CODE
end

### config/secrets.yml ###
append_file 'config/secrets.yml', <<~CODE

  edge:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

  staging:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
CODE

### pg ###
append_file 'config/database.yml', <<~CODE
    host:     <%= ENV['#{@app_name.upcase}_DATABASE_HOST'] %>

  edge:
    <<: *default
    database: #{app_name}_edge
    username: #{app_name}
    password: <%= ENV['#{@app_name.upcase}_DATABASE_PASSWORD'] %>
    host:     <%= ENV['#{@app_name.upcase}_DATABASE_HOST'] %>

  staging:
    <<: *default
    database: #{app_name}_staging
    username: #{app_name}
    password: <%= ENV['#{@app_name.upcase}_DATABASE_PASSWORD'] %>
    host:     <%= ENV['#{@app_name.upcase}_DATABASE_HOST'] %>
CODE

### unicorn ###
UNICORN_CONF_URL = 'http://unicorn.bogomips.org/examples/unicorn.conf.rb'.freeze

inside 'config/unicorn' do
  run "curl -s #{UNICORN_CONF_URL} -o production.rb"
  run 'ln -s production.rb edge.rb'
  run 'ln -s production.rb staging.rb'
end

### unicorn-worker-killer ###
prepend_file 'config.ru', <<~CODE
  # Unicorn self-process killer
  require 'unicorn/worker_killer'

  # Max requests per worker
  max_request_min = (ENV['UNICORN_MAX_REQUEST_MIN'] || 3072).to_i
  max_request_max = (ENV['UNICORN_MAX_REQUEST_MAX'] || 4096).to_i
  use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

  # Max memory size (RSS) per worker
  oom_min = (ENV['UNICORN_OOM_MIN'] || 192).to_i * (1024**2)
  oom_max = (ENV['UNICORN_OOM_MAX'] || 256).to_i * (1024**2)
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max

CODE

### active_model_serializers ###
create_file 'app/serializers/.keep'
create_file 'app/serializers/concerns/.keep'
create_file 'spec/serializers/.keep'

### versionist ###
initializer 'versionist.rb', <<~'CODE'
  module SerializedVersionist
    def add_presenters_base
      in_root do
        create_file "app/serializers/#{module_name_for_path(module_name)}/.keep"
      end
    end

    def add_presenter_test
      in_root do
        create_file "spec/serializers/#{module_name_for_path(module_name)}/.keep"
      end
    end

    def add_helpers_dir
      in_root do
        create_file "app/helpers/#{module_name_for_path(module_name)}/.keep"
      end
    end

    def add_helpers_test_dir
      in_root do
        create_file "spec/helpers/#{module_name_for_path(module_name)}/.keep"
      end
    end

    def add_documentation_base
    end
  end

  class Versionist::NewApiVersionGenerator
    prepend SerializedVersionist
  end
CODE

generate 'versionist:new_api_version v1 V1 --path=value:v1'

### oj ###
initializer 'oj.rb', <<~CODE
  # attempts to be compatible with other systems
  Oj.default_options = { mode: :compat }
CODE

### kaminari ###
generate 'kaminari:config'

### seed-fu ###
create_file 'db/fixtures/.keep'

### config ###
generate 'config:install'
create_file 'config/settings/edge.yml'
create_file 'config/settings/staging.yml'

### dotenv-rails ###
create_file '.env'

### whenever ###
run 'wheneverize .'

### chrono_logger ###
gsub_file 'config/environments/production.rb', /# config\.logger = .+/ do
  'config.logger = ::ChronoLogger.new("#{config.paths[:log][0]}.%Y%m%d")'
end

### exception_notification ###
initializer 'exception_notification.rb', <<~CODE
  require 'exception_notification/rails'

  ExceptionNotification.configure do |config|
    # do not notify in development env and test env
    config.ignore_if do
      Rails.env.development? || Rails.env.test?
    end

    # notification to Slack
    config.add_notifier(
      :slack, webhook_url: Settings.slack.webhook_url,
              channel:     Settings.slack.channel,
              username:    Settings.slack.username,
              additional_parameters: { icon_emoji: Settings.slack.icon },
              http_options: { proxy_address: Settings.proxy.address,
                              proxy_port:    Settings.proxy.port }
    )
  end
CODE

%w(development edge production staging test).each do |env|
  append_file "config/settings/#{env}.yml", <<~CODE
    proxy:
      address: ''
      port:    ''

    slack:
      webhook_url: ''
      channel:     ''
      username:    ''
      icon:        ''
  CODE
end

### pry-rails ###
create_file '.pryrc', "# vim: set ft=ruby:\n"

### hirb ###
append_file '.pryrc', <<~CODE

  ### Hirb ###
  begin
    require 'hirb'
  rescue LoadError
    puts 'no hirb :('
  end

  if defined? Hirb
    # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
    Hirb::View.instance_eval do
      def enable_output_method
        @output_method = true
        @old_print = Pry.config.print
        Pry.config.print = proc do |*args|
          Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
        end
      end

      def disable_output_method
        Pry.config.print = @old_print
        @output_method = nil
      end
    end

    Hirb.enable
  end
CODE

### awesome_print ###
append_file '.pryrc', <<~'CODE'

  ### Awesome Print ###
  begin
    require 'awesome_print'
    Pry.config.print = proc do |output, value|
      Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)
    end
  rescue LoadError
    puts 'no awesome_print :('
  end
CODE

### pry-byebug ###
append_file '.pryrc', <<~CODE

  ### pry-byebug ###
  if defined?(PryByebug)
    Pry.commands.alias_command 'c', 'continue'
    Pry.commands.alias_command 's', 'step'
    Pry.commands.alias_command 'n', 'next'
    Pry.commands.alias_command 'f', 'finish'
  end

  # Hit Enter to repeat last command
  Pry::Commands.command(/^$/, 'repeat last command') do
    _pry_.run_command Pry.history.to_a.last
  end
CODE

### rspec-rails ###
generate 'rspec:install'

comment_lines 'spec/rails_helper.rb', 'config\.fixture_path'
uncomment_lines 'spec/rails_helper.rb', 'spec/support/\*\*/\*\.rb'

create_file 'spec/mailers/.keep'
create_file 'spec/models/.keep'
create_file 'spec/support/utilities.rb'

### factory_girl_rails ###
insert_into_file 'spec/rails_helper.rb', <<-CODE, before: /^end$/

  ### Factory Girl ###
  config.before(:suite) { FactoryGirl.reload }
  config.include FactoryGirl::Syntax::Methods
CODE

### timecop ###
insert_into_file 'spec/rails_helper.rb', <<-CODE, before: /^end$/

  ### timecop ###
  config.after(:each) { Timecop.return }
CODE

### database_rewinder ###
insert_into_file 'spec/rails_helper.rb', <<-CODE, before: /^end$/

  ### DatabaseRewinder ###
  config.before(:suite) { DatabaseRewinder.clean_all }
  config.after(:each) { DatabaseRewinder.clean }
CODE

### fuubar ###
append_file '.rspec', '--format Fuubar'

### simplecov ###
insert_into_file 'spec/rails_helper.rb', "\n\nrequire 'simplecov'",
                 after: /^# Add additional requires below this line.+$/

create_file '.simplecov', <<~CODE
  SimpleCov.start 'rails'

  # vim: set ft=ruby:
CODE

### bullet ###
insert_into_file 'config/environments/test.rb', <<-CODE, before: /^end$/

  ### Bullet ###
  Bullet.enable        = true
  Bullet.bullet_logger = true
  Bullet.raise         = true
CODE

insert_into_file 'spec/rails_helper.rb', <<-CODE, before: /^end$/

  ### Bullet ###
  config.before(:each) { Bullet.start_request }
  config.after(:each) { Bullet.end_request }
CODE

### annotate ###
generate 'annotate:install'

annotate_file = 'lib/tasks/auto_annotate_models.rake'
gsub_file annotate_file, /'routes'\s+=>\s+'false'/ do |match|
  match.sub('false', 'true')
end

### capistrano ###
run 'cap install STAGES=edge,staging,production'

### capistrano-rbenv ###
uncomment_lines 'Capfile', "require 'capistrano/rbenv'"

### capistrano-bundler ###
uncomment_lines 'Capfile', "require 'capistrano/bundler'"

### capistrano-rails ###
uncomment_lines 'Capfile', "require 'capistrano/rails/migrations'"

### capistrano3/unicorn ###
insert_into_file 'Capfile', "require 'capistrano3/unicorn'\n",
                 before: "\n# Load custom tasks from `lib/capistrano/tasks`"

### seed-fu ###
insert_into_file 'Capfile', "require 'seed-fu/capistrano3'\n",
                 before: "\n# Load custom tasks from `lib/capistrano/tasks`"

### whenever ###
insert_into_file 'Capfile', "require 'whenever/capistrano'\n",
                 before: "\n# Load custom tasks from `lib/capistrano/tasks`"

### capistrano-rails-console ###
insert_into_file 'Capfile', "require 'capistrano/rails/console'\n",
                 before: "\n# Load custom tasks from `lib/capistrano/tasks`"

### slackistrano ###
insert_into_file 'Capfile', "require 'slackistrano/capistrano'\n",
                 before: "\n# Load custom tasks from `lib/capistrano/tasks`"

### spring ###
run 'spring binstub --all'

### rubocop ###
COPS = %w(
  Style/DefWithParentheses
  Style/EmptyLineBetweenDefs
  Style/EmptyLines
  Style/EmptyLinesAroundAccessModifier
  Style/EmptyLinesAroundBlockBody
  Style/EmptyLinesAroundClassBody
  Style/EmptyLinesAroundMethodBody
  Style/EmptyLinesAroundModuleBody
  Style/HashSyntax
  Style/IndentationConsistency
  Style/IndentationWidth
  Style/MethodCallParentheses
  Style/MethodDefParentheses
  Style/MultilineOperationIndentation
  Style/SpaceAfterColon
  Style/SpaceAfterComma
  Style/SpaceAfterNot
  Style/SpaceAfterSemicolon
  Style/SpaceAroundEqualsInParameterDefault
  Style/SpaceAroundOperators
  Style/SpaceBeforeSemicolon
  Style/SpaceInsideHashLiteralBraces
  Style/StringLiterals
  Style/TrailingBlankLines
  Style/TrailingWhitespace
).freeze

run "rubocop -a --only #{COPS.join(',')}"

### git init ###
after_bundle do
  remove_file '.git'
  remove_file 'template.rb'

  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
