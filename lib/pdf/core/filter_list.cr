module PDF
  module Core
    class FilterList
      def initialize
        @list = [] of NamedTuple(filter: Symbol, params: Hash(Symbol, Int32) | Symbol | Nil | String)
      end

      def <<(filter)
        case filter
        when Symbol
          @list.push({filter: filter, params: nil})
        when ::NamedTuple
          @list.push(filter)
        else
          raise "Can not interpret input as filter: #{filter.inspect}"
        end

        self
      end

      def normalized
        @list
      end

      # alias_method :to_a, :normalized

      def names
        @list.map do |name|
          name[:filter]
        end
      end

      def decode_params
        @list.map do |params|
          params[:params]
        end
      end

      def inspect
        @list.inspect
      end

      def each
        @list.each do |filter|
          yield(filter)
        end
      end
    end
  end
end
