# encoding: utf-8

# require "./transition"

# puts "PDF::Core specs: Running"

require "spec"
require "expect"
require "../lib/pdf/core"

# require "pdf/reader"
# require "pdf/inspector"

# RSpec.configure do |config|
#   config.treat_symbols_as_metadata_keys_with_true_values = true
# end

# RSpec::Matchers.define :have_parseable_xobjects do
#   match do |actual|
#     expect { PDF::Inspector::XObject.analyze(actual.render) }.not_to raise_error
#     true
#   end
#   failure_message_for_should do |actual|
#     "expected that #{actual}'s XObjects could be successfully parsed"
#   end
# end
