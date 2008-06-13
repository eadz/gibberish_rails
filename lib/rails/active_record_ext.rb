module ActiveRecord #:nodoc:
  class Errors #:nodoc:

    ActiveRecord::Errors.default_error_messages[:inclusion] =
       "is not included in the list"[]
    ActiveRecord::Errors.default_error_messages[:exclusion] =
       "is reserved"[]
    ActiveRecord::Errors.default_error_messages[:invalid] =
       "is invalid"[]
    ActiveRecord::Errors.default_error_messages[:confirmation] =
       "doesn't match confirmation"[]
    ActiveRecord::Errors.default_error_messages[:accepted ] =
       "must be accepted"[]
    ActiveRecord::Errors.default_error_messages[:empty] =
       "can't be empty"[]
    ActiveRecord::Errors.default_error_messages[:blank] =
       "can't be blank"[]
    ActiveRecord::Errors.default_error_messages[:too_long] =
       "is too long (maximum is %d characters)"[]
    ActiveRecord::Errors.default_error_messages[:too_short] =
       "is too short (minimum is %d characters)"[]
    ActiveRecord::Errors.default_error_messages[:wrong_length] =
       "is the wrong length (should be %d characters)"[]
    ActiveRecord::Errors.default_error_messages[:taken] =
       "has already been taken"[]
    ActiveRecord::Errors.default_error_messages[:not_a_number] =
       "is not a number"[]
    ActiveRecord::Errors.default_error_messages[:greater_than] =
       "must be greater than %d"[]
    ActiveRecord::Errors.default_error_messages[:greater_than_or_equal_to] =
       "must be greater than or equal to %d"[]
    ActiveRecord::Errors.default_error_messages[:equal_to] =
       "must be equal to %d"[]
    ActiveRecord::Errors.default_error_messages[:less_than] =
       "must be less than %d"[]
    ActiveRecord::Errors.default_error_messages[:less_than_or_equal_to] =
       "must be less than or equal to %d"[]
    ActiveRecord::Errors.default_error_messages[:odd] =
       "must be odd"[]
    ActiveRecord::Errors.default_error_messages[:even] =
       "must be even"[]

    # This replaces rails core add so the message can be re-translated when 
    # we are in the around filter.   This is a total hack that uses the 
    # entire english message as a key to retranslate it.
		#
#    def add(attribute, msg = @@default_error_messages[:invalid])
#      attribute_s = attribute.to_s
#      if attribute != :base
#        tmp_msg = msg[msg.tr('[   ]', '_').to_sym]
#        msg = tmp_msg if tmp_msg != nil
#        tmp_attr = attribute_s[attribute]
#        attribute_s = tmp_attr if tmp_attr
#      end
#      @errors[attribute_s] = [] if @errors[attribute_s].nil?
#      @errors[attribute_s] << msg
#    end
  end

  module Validations
    module ClassMethods

      # Exactly like rails 2.0.2, except too_short, to_long translated
			#
      def validates_length_of(*attrs)
        # Merge given options with defaults.
        options = {
          :too_long     => ActiveRecord::Errors.default_error_messages[:too_long],
          :too_short    => ActiveRecord::Errors.default_error_messages[:too_short],
          :wrong_length => ActiveRecord::Errors.default_error_messages[:wrong_length]
        }.merge(DEFAULT_VALIDATION_OPTIONS)
        options.update(attrs.extract_options!.symbolize_keys)

        # Ensure that one and only one range option is specified.
        range_options = ALL_RANGE_OPTIONS & options.keys
        case range_options.size
          when 0
            raise ArgumentError, 'Range unspecified.  Specify the :within, :maximum, :minimum, or :is option.'
          when 1
            # Valid number of options; do nothing.
          else
            raise ArgumentError, 'Too many range options specified.  Choose only one.'
        end

        # Get range option and value.
        option = range_options.first
        option_value = options[range_options.first]

        myfirst = true

        case option
          when :within, :in
            raise ArgumentError, ":#{option} must be a Range" unless option_value.is_a?(Range)

            validates_each(attrs, options) do |record, attr, value|

              if myfirst == true
                myfirst = false
                too_short = options[:too_short][options[:too_short].tr('[   ]', '_').to_sym] % option_value.begin
                too_long  = options[:too_long][options[:too_long].tr('[   ]', '_').to_sym] % option_value.end
              end

              if value.nil? or value.split(//).size < option_value.begin
                record.errors.add(attr, too_short)
              elsif value.split(//).size > option_value.end
                record.errors.add(attr, too_long)
              end
            end
          when :is, :minimum, :maximum
            raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0

            # Declare different validations per option.
            validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
            message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

            message = (options[:message] || options[message_options[option]]) % option_value

            validates_each(attrs, options) do |record, attr, value|
              if value.kind_of?(String)
                record.errors.add(attr, message) unless !value.nil? and value.split(//).size.method(validity_checks[option])[option_value]
              else
                record.errors.add(attr, message) unless !value.nil? and value.size.method(validity_checks[option])[option_value]
              end
            end
        end
      end
    end
  end
end
