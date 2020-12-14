require 'rake/clean'

require 'json'
require 'uri'
require 'dotenv/tasks'

# Disable FileUtils logging statements
verbose(false)

CLEAN << '.build'
CLEAN << File.expand_path('~/Library/Caches/org.swift.swiftpm/repositories/')

CLEAN << 'Package.resolved'
file 'Package.resolved' => ['Package.swift'] do
  `swift package resolve`
end

CLOBBER << 'dependencies.json'
desc 'Generate a list of dependencies'
file 'dependencies.json' => ['Package.resolved'] do |t|
  resolved = JSON(File.read(t.prerequisites.first))

  dependencies = []
  resolved['object']['pins'].each do |pin|
    dependencies << {
      url: pin['repositoryURL'],
      version: pin['state']['version']
    }
  end

  File.write(t.name, dependencies.to_json)
end

CLEAN << '.swiftpm/config'
directory '.swiftpm'
file '.swiftpm/config' => [:dotenv, '.swiftpm', 'dependencies.json'] do |t|
  raise 'Missing environment variable SWIFT_REGISTRY_URL' unless ENV['SWIFT_REGISTRY_URL']

  dependencies = JSON(File.read(t.prerequisites.last))

  dependencies.each do |dependency|
    original_url = URI(dependency['url'].sub(/\.git$/, ''))
    mirror_url = URI(ENV['SWIFT_REGISTRY_URL'])
    mirror_url.path = ("/" + original_url.host + original_url.path).squeeze("/")
    `swift package config set-mirror --original-url #{original_url} --mirror-url #{mirror_url}`
  end
end

CLOBBER << '.index'
directory '.index' => ['dependencies.json'] do |t|
  `swift registry init --index #{t.name}`

  dependencies = JSON(File.read(t.prerequisites.first))

  dependencies.each do |dependency|
    url = URI(dependency['url'].sub(/\.git$/, ''))
    package = url.host + url.path
    version = dependency['version'].sub(/^v?/, '')

    `swift registry publish #{package} #{version} --index #{t.name}`
  end
end

CLEAN << 'spm'
file 'spm' => [:dotenv] do |t|
  raise 'Missing environment variable SWIFT_PACKAGE_MANAGER_BUILD_PATH' unless ENV['SWIFT_PACKAGE_MANAGER_BUILD_PATH']

  build_path = File.expand_path(ENV['SWIFT_PACKAGE_MANAGER_BUILD_PATH'])
  subcommands = %w[build package test run]

  File.open(t.name, 'w') do |f|
    f << <<~SH
      #!/usr/bin/env bash

      set -eo pipefail

      if [ -z "$1" ]; then
          echo "missing subcommand [#{subcommands.join('|')}]"
          exit 1
      fi

      BUILD_PATH="#{build_path}"

    SH

    f.puts 'case "$1" in'
    subcommands.each do |c|
      f.puts %(#{c}\) "$BUILD_PATH/swift-#{c}" "${@:2}" ;;)
    end
    f.puts 'esac'
  end

  chmod '+x', t.name
end

namespace :registry do
  task start: ['.index', 'registry:stop'] do |t|
    IO.popen(['swift-registry', 'serve', '--index', t.prerequisites.first])
    sleep 1
  end

  task :stop do
    system 'pkill -f swift-registry'
  end
end

namespace :benchmark do
  task repository: [:clean] do
    puts command = 'time swift run'
    system command
  end

  task registry: [:clean, '.swiftpm/config', 'spm'] do
    begin
      rm 'Package.resolved'
    rescue StandardError
      nil
    end
    puts command = 'time ./spm run --enable-package-registry'
    system command
  end

  task all: %i[repository registry]
end

Rake::Task['benchmark:registry'].enhance ['registry:start']
Rake::Task['benchmark:registry'].enhance do
  Rake::Task['registry:stop'].invoke
end

task benchmark: 'benchmark:all'
