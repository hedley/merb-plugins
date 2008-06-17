module Merb
  module Helpers
    module Form
      
      def _singleton_form_context
        @_singleton_form_context ||= 
          self._form_class.new(nil, nil, self)
      end
      
      def form_contexts
        @_form_contexts ||= []
      end
      
      def current_form_context
        form_contexts.last || _singleton_form_context
      end

      def _new_form_context(name, builder)
        if name.is_a?(String) || name.is_a?(Symbol)
          ivar = instance_variable_get("@#{name}")
        else
          ivar, name = name, name.class.to_s.snake_case
        end
        builder ||= current_form_context.class if current_form_context
        (builder || self._form_class).new(ivar, name, self)
      end
      
      def with_form_context(name, builder)
        form_contexts.push(_new_form_context(name, builder))
        yield
        form_contexts.pop
      end
      
      def form_tag(*args, &blk)
        _singleton_form_context.form_tag(*args, &blk)
      end
            
      def form_for(name, attrs = {}, &blk)
        with_form_context(name, attrs.delete(:builder)) do
          current_form_context.form_tag(attrs, &blk)
        end
      end
      
      def fields_for(name, attrs = {}, &blk)
        attrs ||= {}
        with_form_context(name, attrs.delete(:builder)) do
          current_form_context.concat(attrs, &blk)
        end
      end
      
      %w(text radio password hidden checkbox radio_group).each do |kind|
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{kind}_control(name, attrs = {})
            current_form_context.#{kind}_control(name, attrs)
          end
          
          def #{kind}_field(attrs = {})
            _singleton_form_context.#{kind}_field(attrs)
          end
        RUBY
      end
      
    end
  end
end