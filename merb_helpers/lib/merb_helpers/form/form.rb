module Merb
  class Form
    def initialize(obj, name, origin)
      @obj, @origin = obj, origin
      @name = name || @obj.class.name.snake_case.split("/").last
    end
    
    def concat(attrs, &blk)
      @origin.concat(@origin.capture(&blk), blk.binding)
    end
    
    def form_tag(attrs = {}, &blk)
      fake_method_tag = process_form_attrs(attrs)
      
      contents = tag(:form, fake_method_tag + @origin.capture(&blk), attrs)
      @origin.concat(contents, blk.binding)
    end
    
    def process_form_attrs(attrs)
      method = attrs[:method]

      # Unless the method is :get, fake out the method using :post
      attrs[:method] = :post unless attrs[:method] == :get
      # Use a fake PUT if the object is not new, otherwise use the method
      # passed in.
      method = @obj && !@obj.new_record? ? :put : method || :post
      
      attrs[:enctype] = "multipart/form-data" if attrs.delete(:multipart)
      
      method == :post || method == :get ? "" : fake_out_method(attrs, method)
    end
    
    # This can be overridden to use another method to fake out methods
    def fake_out_method(attrs, method)
      self_closing_tag(:input, :type => "hidden", 
        :name => "_method", :value => method)
    end
    
    def add_class(attrs, new_class)
      attrs[:class] = (attrs[:class].to_s.split(" ") + [new_class]).join(" ")
    end
    
    def text_control(method, attrs)
      name = "#{@name}[#{method}]"
      text_field(attrs.merge(:name => name, :value => @obj.send(method)))
    end
    
    def text_field(attrs)
      self_closing_tag(:input, {:type => "text"}.merge(attrs))
    end
  end
  
  class CompleteForm < Form
    def text_control(method, attrs)
      attrs.merge!(:id => "#{@name}_#{method}")
      super
    end
    
    def text_field(attrs)
      add_class(attrs, "text")
      label(attrs) + super
    end
    
    def label(attrs)
      (label_text = attrs.delete(:label)) ? tag(:label, label_text) : ""
    end
  end
  
  class CompleteFormWithErrors < CompleteForm
    def text_control(method, attrs)
      errorify_attrs(method, attrs)
      super
    end
    
    def errorify_attrs(method, attrs)
      if @obj.errors.on(method.to_sym)
        add_class(attrs, "error")
      end
    end
  end
  
end