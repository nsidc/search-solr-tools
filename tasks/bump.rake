# frozen_string_literal: true

require 'bump'

namespace :bump do
  desc 'Bump to a pre-release version'
  task :pre do
    bump_and_push('pre')
  end

  desc 'Bump to a patch release version'
  task :patch do
    bump_and_push('patch')
  end

  desc 'Bump to a minor release version'
  task :minor do
    bump_and_push('minor')
  end

  desc 'Bump to a major release version'
  task :major do
    bump_and_push('major')
  end
end

def bump_and_push(version_part)
  update_changelog(Bump::Bump.next_version(version_part))
  Bump::Bump.run(version_part, tag: true, commit: true, changelog: false)

  sh %(git push origin HEAD --tags)
end

def version_rb
  File.join(root, 'lib', 'search_solr_tools', 'version.rb')
end

def changelog_md
  File.join(root, 'CHANGELOG.md')
end

def update_changelog(version)
  date = Time.now.strftime('%Y-%m-%d')
  sh %(sed -i "s/^## Unreleased$/## v#{version} (#{date})/" #{changelog_md})
  sh %(git add #{changelog_md})
end

# The very top of the working directory.
def root
  spec.gem_dir
end

def spec
  Gem::Specification.find_by_name('search_solr_tools')
end
