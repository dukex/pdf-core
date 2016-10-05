# encoding: utf-8

# prawn/core/filters.rb : Implements stream filters
#
# Copyright February 2013, Alexander Mankuta.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "zlib"

module PDF
  module Core
    module Filters
      module FlateDecode
        def self.encode(stream, params = nil)
          Zlib::Deflate.gzip(stream)
        end

        def self.decode(stream, params = nil)
          Zlib::Inflate.gzip(stream) do |s|
            s.gets_to_end
          end
        end
      end

      # Pass through stub
      module DCTDecode
        def self.encode(stream, params = nil)
          stream
        end

        def self.decode(stream, params = nil)
          stream
        end
      end

      def self.get(type = :FlateDecode)
        PDF::Core::Filters::FlateDecode
      end

      # def self.get(type = :DCTDecode)
      #   PDF::Core::Filters::DCTDecode
      # end
    end
  end
end
