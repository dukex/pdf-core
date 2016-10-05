# encoding: utf-8

# prawn/core/stream.rb : Implements Stream objects
#
# Copyright February 2013, Alexander Mankuta.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module PDF
  module Core
    class Stream
      # attr_reader :filters
      getter :filters

      def initialize(io = "")
        @filtered_stream = ""
        @stream = io
        @filters = FilterList.new
      end

      def <<(io)
        @stream += io
        @filtered_stream = ""
        self
      end

      def compress!
        unless @filters.names.includes? :FlateDecode
          @filtered_stream = ""
          @filters << :FlateDecode
        end
      end

      def compressed?
        @filters.names.includes? :FlateDecode
      end

      def empty?
        @stream.nil?
      end

      def filtered_stream
        if @stream
          if @filtered_stream == ""
            @filtered_stream = @stream.dup

            @filters.each do |filter_data|
              if filter = get_filter(filter_data[:filter])
                @filtered_stream = filter.encode(MemoryIO.new(@filtered_stream), filter_data[:params]).to_s
              end
            end
          end

          @filtered_stream.not_nil!
          # XXX Fillter stream
        else
          ""
        end
      end

      def size
        @stream.size
      end

      def object
        if filtered_stream
          "stream\n#{filtered_stream}\nendstream\n"
        else
          ""
        end
      end

      def data
        if @stream
          filter_names = @filters.names
          filter_params = @filters.decode_params

          d = Hash(Symbol, Array(Symbol) | Int32 | Array(String | Nil) | Array(Hash(Symbol, Int32) | Symbol | Nil | String)){:Length => filtered_stream.size}

          if filter_names.any?
            d[:Filter] = filter_names
          end

          if filter_params.any? { |f| !f.nil? }
            d[:DecodeParms] = filter_params
          end

          d
        else
          {} of Symbol => Nil
        end
      end

      def inspect
        "#<#{self.class.name}:0x#{"%014x" % object_id} @stream=#{@stream.inspect}, @filters=#{@filters.inspect}>"
      end

      macro get_filter(name)
        PDF::Core::Filters.get({{name.id}})
      end
    end
  end
end
