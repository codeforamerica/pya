class Form
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  def self.form_param
    name.delete("::").underscore
  end
end
