load File.dirname(__FILE__) / "tag_helpers.rb"
load File.dirname(__FILE__) / "form" / "helpers.rb"
load File.dirname(__FILE__) / "form" / "form.rb"

class Merb::Controller
  class_inheritable_accessor :_form_class
  include Merb::Helpers::Form  
end

Merb::BootLoader.after_app_loads do

  Merb::Plugins.config[:helpers][:form_class] ||= Merb::Form

  class Merb::Controller
    self._form_class = Merb::Plugins.config[:helpers][:form_class]
  end

end