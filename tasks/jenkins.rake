def metadata_json
  File.expand_path('../../metadata.json', __FILE__)
end

# Load will reload the version file so we can get the updated value
# after bumping it.
def current_version
  version = JSON.load(File.new(metadata_json))['version']
  version
end

namespace :jenkins do
  namespace :ci do
    desc 'Run RuboCop'
    task :rubocop do
      sh 'bundle exec rubocop --display-cop-names'
    end

    desc 'Run RSpec unit tests'
    task unit: [:'rake:spec:unit']

    desc 'Run integration tests with a test VM'
    task integration: [:'rake:spec:acceptance']
  end

  namespace :release do

    date = Time.now.strftime('%Y-%m-%d')

    desc 'Bump version part (patch/minor/major), set release date in CHANGELOG, make tag'
    task :bump, [:part] do |t, args|
      args.with_defaults(part: 'patch')

      # bump VERSION in version.rb, stage version.rb (this requires that you
      # have the bump gem installed with Bundler)
      sh "bundle exec rake bump[#{args[:part]}]"
      sh "git add #{metadata_json}"

      # get the new version after bumping it
      version = current_version

      # change "Unreleased" version to current version, with a release date of
      # today, stage CHANGELOG.md
      changelog_md = File.expand_path('../../CHANGELOG.md', __FILE__)
      sh %(sed -i "s/^## Unreleased$/## v#{version} (#{date})/" #{changelog_md})
      sh %(git add #{changelog_md})

      # commit changes and tag
      sh %(git commit -m "v#{version}")
      sh %(git tag v#{version})
    end

    desc 'git-tag the current commit for release'
    task :tag do
      sh "git tag v#{version}"
    end

    desc 'git-push the release changes (the version bump commit and the version tag)'
    task :push do
      sh 'git push origin master'
      sh 'git push origin --tags'
    end
  end
end
