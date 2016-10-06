# encoding: utf-8
#
# pdf_object.rb : Handles Ruby to PDF object serialization
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

# Top level Module
#
module PDF
  module Core
    # module_function

    def self.real(num)
      num.to_f.round(4)
    end

    def self.real_params(array)
      array.map { |e| real(e) }.join(" ")
    end

    def self.utf8_to_utf16(str)
      # "\xFE\xFF".force_encoding(::Encoding::UTF_16BE) + str.encode(::Encoding::UTF_16BE)
      str
    end

    # encodes any string into a hex representation. The result is a string
    # with only 0-9 and a-f characters. That result is valid ASCII so tag
    # it as such to account for behaviour of different ruby VMs
    def self.string_to_hex(str)
      # str.unpack("H*").first.force_encoding(::Encoding::US_ASCII)
      str.to_i(16)
    end

    # Serializes Ruby objects to their PDF equivalents.  Most primitive objects
    # will work as expected, but please note that Name objects are represented
    # by Ruby Symbol objects and Dictionary objects are represented by Ruby hashes
    # (keyed by symbols)
    #
    #  Examples:
    #
    #     pdf_object(true)      #=> "true"
    #     pdf_object(false)     #=> "false"
    #     pdf_object(1.2124)    #=> "1.2124"
    #     pdf_object("foo bar") #=> "(foo bar)"
    #     pdf_object(:Symbol)   #=> "/Symbol"
    #     pdf_object(["foo",:bar, [1,2]]) #=> "[foo /bar [1 2]]"
    #
    def self.pdf_object(obj : Nil, in_content_stream = false)
      "null"
    end

    def self.pdf_object(obj : Bool, in_content_stream = false)
      obj ? "true" : false
    end

    def self.pdf_object(obj : Int32, in_content_stream = false)
      obj = real(obj) unless obj.kind_of?(Integer)
      obj.to_s
    end

    def self.pdf_object(obj : PDF::Core::Reference, in_content_stream = false)
      obj.to_s
    end

    def self.pdf_object(obj : PDF::Core::NameTree::Node, in_content_stream = false)
      pdf_object(obj.to_hash)
    end

    def self.pdf_object(obj : PDF::Core::NameTree::Value, in_content_stream = false)
      pdf_object(obj.name) + " " + pdf_object(obj.value)
    end

    def self.pdf_object(obj : PDF::Core::OutlineRoot | PDF::Core::OutlineItem, in_content_stream = false)
      pdf_object(obj.to_hash)
    end

    def self.pdf_object(obj : Array, in_content_stream = false)
      "[" + obj.map { |e| pdf_object(e, in_content_stream) }.join(' ') + "]"
    end

    def self.pdf_object(obj : PDF::Core::LiteralString, in_content_stream = false)
      obj = obj.gsub(/[\\\n\r\t\b\f\(\)]/) { |m| "\\#{m}" }
      "(#{obj})"
    end

    def self.pdf_object(obj : Time, in_content_stream = false)
      obj = obj.strftime("D:%Y%m%d%H%M%S%z").chop.chop + "'00'"
      obj = obj.gsub(/[\\\n\r\t\b\f\(\)]/) { |m| "\\#{m}" }
      "(#{obj})"
    end

    def self.pdf_object(obj : PDF::Core::ByteString, in_content_stream = false)
      "<" + obj.unpack("H*").first + ">"
    end

    def self.pdf_object(obj : String, in_content_stream = false)
      obj = utf8_to_utf16(obj) unless in_content_stream
      "<" + string_to_hex(obj) + ">"
    end

    def self.pdf_object(obj : Symbol, in_content_stream = false)
      "/" + obj.to_s.unpack("C*").map { |n|
        if n < 33 || n > 126 || [35, 40, 41, 47, 60, 62].include?(n)
          "#" + n.to_s(16).upcase
        else
          [n].pack("C*")
        end
      }.join
    end

    def self.pdf_object(obj : ::Hash, in_content_stream = false)
      output = "<< "
      obj.each do |k, v|
        unless String === k || Symbol === k
          raise PDF::Core::Errors::FailedObjectConversion,
            "A PDF Dictionary must be keyed by names"
        end
        output << pdf_object(k.to_sym, in_content_stream) << " " <<
          pdf_object(v, in_content_stream) << "\n"
      end
      output << ">>"
    end
  end
end
