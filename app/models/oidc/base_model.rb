class OIDC::BaseModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  include SemanticLogger::Loggable

  concerning "Inspectable" do
    included do
      # Returns the contents of the record as a nicely formatted string.
      def inspect
        # We check defined?(@attributes) not to issue warnings if the object is
        # allocated but not initialized.
        inspection = if defined?(@attributes) && @attributes
                       attribute_names.filter_map do |name|
                         "#{name}: #{_read_attribute(name)}" if @attributes.key?(name)
                       end.join(", ")
                     else
                       "not initialized"
                     end

        "#<#{self.class} #{inspection}>"
      end

      # Takes a PP and prettily prints this record to it, allowing you to get a nice result from <tt>pp record</tt>
      # when pp is required.
      def pretty_print(pp)
        pp.object_address_group(self) do
          if defined?(@attributes) && @attributes
            attr_names = attribute_names.select { |name| @attributes.key?(name) }
            pp.seplist(attr_names, proc { pp.text "," }) do |attr_name|
              pp.breakable " "
              pp.group(1) do
                pp.text attr_name
                pp.text ":"
                pp.breakable
                value = _read_attribute(attr_name)
                pp.pp value
              end
            end
          else
            pp.breakable " "
            pp.text "not initialized"
          end
        end
      end
    end
  end

  concerning "Attributes" do
    included do
      def [](attr_name)
        _read_attribute(attr_name) { |n| missing_attribute(n, caller) }
      end
    end
  end
end
