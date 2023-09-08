# frozen_string_literal: true

namespace :bump do
  desc 'Bump to a pre-release version'
  task :pre do |_t, args|
    sh 'gem bump --push --version pre --tag'
  end

  desc 'Bump to a patch release version'
  task :patch do
    sh 'gem bump --push --version patch --tag'
  end

  desc 'Bump to a minor release version'
  task :minor do
    sh 'gem bump --push --version minor --tag'
  end

  desc 'Bump to a major release version'
  task :major do
    sh 'gem bump --push --version major --tag'
  end
end