# encoding: utf-8

require "./spec_helper"

describe "A Reference object" do
  it "should produce a PDF reference on #to_s call" do
    ref = PDF::Core::Reference.new(1, true)
    ref.to_s.should eq("1 0 R")
  end

  it "should allow changing generation number" do
    ref = PDF::Core::Reference.new(1,true)
    ref.gen = 1
    ref.to_s.should eq("1 1 R")
  end

  it "should generate a valid PDF object for the referenced data" do
    ref = PDF::Core::Reference.new(2,[1,"foo"])
    ref.object.should eq("2 0 obj\n#{PDF::Core.pdf_object([1,"foo"])}\nendobj\n")
  end

  it "should include stream fileds in dictionary when serializing" do
     ref = PDF::Core::Reference.new(1)
     ref.stream << "Hello"
     ref.object.should  eq("1 0 obj\n<< /Length 5\n>>\nstream\nHello\nendstream\nendobj\n")
  end

  it "should append data to stream when #<< is used" do
     ref = PDF::Core::Reference.new(1)
     ref << "BT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET"
     ref.object.should  eq("1 0 obj\n<< /Length 41\n>>\nstream"+
                           "\nBT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET" +
                           "\nendstream\nendobj\n")
  end

  it "should copy the data and stream from another ref on #replace" do
    from = PDF::Core::Reference.new(3, {:foo => "bar"})
    from << "has a stream too"

    to = PDF::Core::Reference.new(4, {:foo => "baz"})
    to.replace from

    # should preserve identifier but copy data and stream
    to.identifier.should eq(4)
    to.data.should eq(from.data)
    to.stream.should eq(from.stream)
  end

  it "should copy a compressed stream from a compressed ref on #replace" do
    from = PDF::Core::Reference.new(5, {:foo => "bar"})
    from << "has a stream too " * 20
    from.stream.compress!

    to = PDF::Core::Reference.new(6, {:foo => "baz"})
    to.replace from

    to.identifier.should eq(6)
    to.data.should eq(from.data)
    to.stream.should eq(from.stream)
    to.stream.compressed?.should eq(true)
  end
end
