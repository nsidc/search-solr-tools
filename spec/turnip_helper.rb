require 'yarjuf'

Dir.glob('spec/acceptance/steps/**/*steps.rb') { |f| load f, true }
