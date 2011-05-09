class Hash

  def with_method_access
    class << self
      def method_missing name, *args
        if name[-1] == '='
          self[name[0..-2].to_sym] = args[0]
        elsif has_key? name
          self[name]
        else
          super
        end
      end
    end
    self
  end

end