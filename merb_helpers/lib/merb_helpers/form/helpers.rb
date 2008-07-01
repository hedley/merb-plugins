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
        ret = yield
        form_contexts.pop
        ret
      end

      def form(*args, &blk)
        _singleton_form_context.form(*args, &blk)
      end

      def form_for(name, attrs = {}, &blk)
        with_form_context(name, attrs.delete(:builder)) do
          current_form_context.form(attrs, &blk)
        end
      end

      def fields_for(name, attrs = {}, &blk)
        attrs ||= {}
        with_form_context(name, attrs.delete(:builder)) do
          current_form_context.concat(attrs, &blk)
        end
      end

      def fieldset(attrs = {}, &blk)
        _singleton_form_context.fieldset(attrs, &blk)
      end

      def fieldset_for(name, attrs = {}, &blk)
        with_form_context(name, attrs.delete(:builder)) do
          current_form_context.fieldset(attrs, &blk)
        end
      end

      %w(text radio password hidden checkbox
      radio_group text_area select file).each do |kind|
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{kind}_control(*args)
            current_form_context.#{kind}_control(*args)
          end

          def #{kind}(*args)
            _singleton_form_context.#{kind}(*args)
          end
        RUBY
      end

      def button(contents, attrs = {})
        _singleton_form_context.button(contents, attrs)
      end

      def submit(contents, attrs = {})
        _singleton_form_context.submit(contents, attrs)
      end
      
      def error_messages_for(obj = nil, opts = {})
        current_form_context.error_messages_for(obj, opts[:error_class] || "error", 
          opts[:build_li] || "<li>%s</li>", 
          opts[:header] || "<h2>Form submission failed because of %s problem%s</h2>",
          opts.key?(:before) ? opts[:before] : true)
      end
      alias error_messages error_messages_for
      
    end
  end
end
