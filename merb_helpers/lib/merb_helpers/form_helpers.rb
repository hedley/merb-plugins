load File.dirname(__FILE__) / "tag_helpers.rb"
load File.dirname(__FILE__) / "form" / "helpers.rb"
load File.dirname(__FILE__) / "form" / "form.rb"

Merb::Plugins.config[:helpers] ||= {}
Merb::Plugins.config[:helpers][:form_class] ||= Merb::Form

class Merb::Controller
  class_inheritable_accessor :_form_class
  self._form_class = Merb::Plugins.config[:helpers][:form_class]
  
  include Merb::Helpers::Form
end
