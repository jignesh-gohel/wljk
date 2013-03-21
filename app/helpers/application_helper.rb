module ApplicationHelper
  # Reference: http://stackoverflow.com/questions/4541075/what-is-the-devise-mapping-variable-and-how-can-i-include-it
  def devise_mapping
    Devise.mappings[:user]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end
end
