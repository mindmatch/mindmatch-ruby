module MindMatch
  class QueryBuilder
    def initialize
      @fields = {}
    end

    def build
      @fields = @fields.freeze
      self
    end

    def to_h
      Hash[
        fields.map { |k, _v| [k, []] }
      ]
    end

    def to_s
      ''.tap do |s|
        fields.each do |k, v|
          s << "#{k} {\n"
          s << v.join("\n")
          s << "}\n"
        end
      end
    end

    private

    attr_reader :fields

    def method_missing(m, *args, &block)
      method = m.to_s
      if method.start_with?('with_')
        key = method.split('with_')[1]
        @fields[key] = args[0]
        self
      else
        super(m, *args, &block)
      end
    end
  end
end
