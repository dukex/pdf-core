# encoding: utf-8

# reference.rb : Implementation of PDF indirect objects
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module PDF
  module Core
    class Reference # :nodoc:

      # attr_accessor :gen, :data, :offset, :stream, :identifier
      property :gen
      getter :data

      def initialize(id : Int32)
        @identifier = id
        @gen = 0
        @stream = Stream.new
        @data = nil
      end

      def initialize(id : Int32, data : String)
        initialize id
        @data = data
      end

      def initialize(id : Int32, data : Bool)
        initialize id
        @data = data
      end

      def initialize(id : Int32, data : Array(Int32 | String))
        initialize id
        @stream = Stream.new
      end

      def object
        output = "#{@identifier} #{gen} obj\n"
        unless @stream.empty?
          output << PDF::Core.pdf_object(data.merge @stream.data) << "\n" << @stream.object
        else
          output << PDF::Core.pdf_object(data) << "\n"
        end

        output << "endobj\n"
      end

      def <<(io)
        raise "Cannot attach stream to non-dictionary object" unless @data.is_a?(::Hash)
        (@stream ||= Stream.new) << io
      end

      def to_s
        "#{@identifier} #{gen} R"
      end

      # Creates a deep copy of this ref. If +share+ is provided, shares the
      # given dictionary entries between the old ref and the new.
      #
      def deep_copy(share = [] of String)
        r = dup

        case r.data
        when ::Hash
          # Copy each entry not in +share+.
          (r.data.keys - share).each do |k|
            r.data[k] = Marshal.load(Marshal.dump(r.data[k]))
          end
        when PDF::Core::NameTree::Node
          r.data = r.data.deep_copy
        else
          r.data = Marshal.load(Marshal.dump(r.data))
        end

        r.stream = Marshal.load(Marshal.dump(r.stream))
        r
      end

      # Replaces the data and stream with that of other_ref.
      def replace(other_ref)
        @data = other_ref.data
        @stream = other_ref.stream
      end
    end

    def reference(*args, &block) # :nodoc:
      Reference.new(*args, &block)
    end
  end
end
