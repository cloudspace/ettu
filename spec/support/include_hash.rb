RSpec::Matchers.define :include_hash do |expected|
  match do |actual|
    !actual.nil? && !actual.empty? && (actual.to_a & expected.to_a) == expected.to_a
  end
end
