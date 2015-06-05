guard :rspec, spec_paths: ['spec/unit'], keep_failed: true, all_after_pass: true, all_on_start: true do
  watch %r{/^spec\/.+_spec\.rb/}
  watch(%r{/^lib\/(.+)\.rb/}) { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{spec/unit/fixtures/(.+)\.xml}) { |m| File.dirname(m[0]) }
end

guard :rubocop do
  watch(%r{/.+\.(rb|rake)/})
  watch(%r{/(Guard|Rake)file/})
  watch(%r{/(?:.+\/)?\.rubocop\.yml/}) { |m| File.dirname(m[0]) }
end
