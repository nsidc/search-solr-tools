namespace :release do
  desc 'Create a new prerelease, optionally publishing to rubygems.org'
  task :pre, :publish do |_t, args|
    cmd = 'gem bump --push --version pre'
    cmd.concat(' --tag --release') if args.publish == 'true'

    sh cmd
  end

  desc 'Create a new release, dropping the current prerelease version, publish to rubygems.org'
  task :none do
    sh 'gem bump --tag --release --version release'
    sh 'gem bump --push --version pre'
  end

  desc 'Create a new release with a minor version bump, publish to rubygems.org'
  task :minor do
    sh 'gem bump --tag --release --version minor'
    sh 'gem bump --push --version pre'
  end

  desc 'Create a new release with a major version bump, publish to rubygems.org'
  task :major do
    sh 'gem bump --tag --release --version major'
    sh 'gem bump --push --version pre'
  end
end
