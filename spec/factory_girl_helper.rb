def build_attributes(*args) #returns attributes with saved associations
  FactoryGirl.build(*args).attributes.delete_if do |k, v|
    ['id', 'created_at', 'updated_at'].member?(k)
  end
end
