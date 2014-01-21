module Zimbra
  class Appointment
    class RecurException
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          return nil unless zimbra_attributes
          new(parse_zimbra_attributes(zimbra_attributes))
        end
        
        def parse_zimbra_attributes(zimbra_attributes)
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)

          {
            :recurrence_id => zimbra_attributes[:d],
            :timezone => zimbra_attributes[:tz],
            :range_type => zimbra_attributes[:rangeType]
          }
        end
      end
      
      ATTRS = [
        :recurrence_id,
        :timezone,
        :range_type
      ] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
    
      def range_type=(val)
        @range_type = parse_range_type(val)
      end
    
      def initialize(args = {})
        self.attributes = args
      end
    
      # take attributes by the xml name or our more descriptive name
      def attributes=(args = {})
        ATTRS.each do |attr_name|
          self.send(:"#{attr_name}=", (args[attr_name] || args[attr_name.to_s]))
        end
      end
      
      def to_hash(options = {})
        hash = ATTRS.inject({}) do |attr_hash, attr_name|
          attr_hash[attr_name] = self.send(:"#{attr_name}")
          attr_hash
        end
        hash.reject! { |key, value| options[:except].include?(key.to_sym) || options[:except].include?(key.to_s) } if options[:except]
        hash.reject! { |key, value| !options[:only].include?(key.to_sym) && !options[:only].include?(key.to_s) } if options[:only]
        hash
      end
      
      private
      
      def parse_range_type(val)
        possible_values = {
          1 => :none,
          2 => :this_and_future,
          3 => :this_and_prior
        }
        
        int_val = val.to_int rescue nil
        
        possible_values[int_val] || val
      end
    end
  end
end
