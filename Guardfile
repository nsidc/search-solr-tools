guard :rspec, spec_paths: ['spec/lib'], all_on_start: true do
  watch(/^spec\/.+_spec\.rb/)
  watch(/^lib\/(.+)\.rb/) { |m| "spec/lib/#{m[1]}_spec.rb" }
end

guard :rubocop do
  watch(/.+\.(rb|rake)/)
  watch(/(Gem|Guard|Rake)file/)
  watch(/(?:.+\/)?\.rubocop\.yml/) { |m| File.dirname(m[0]) }
end
