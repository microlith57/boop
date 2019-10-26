# frozen_string_literal: true

require 'rubocop/rake_task'
require 'reek/rake/task'
require 'haml_lint/rake_task'

namespace 'lint' do
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = false
  end

  Reek::Rake::Task.new(:reek) do |t|
    t.fail_on_error = false
  end

  HamlLint::RakeTask.new(:haml) do |t|
    t.fail_level = 'error'
  end

  task all: %i[rubocop reek haml]

  namespace 'ci' do
    RuboCop::RakeTask.new(:rubocop)
    Reek::Rake::Task.new(:reek)
    HamlLint::RakeTask.new(:haml)

    task all: %i[rubocop reek haml]
  end
end
