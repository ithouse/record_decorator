module RecordDecorator
  class Decorator
    class << self
      def decorate_association(owner, target)
        if owner.respond_to?(:__record_decorator)
          decorate target, owner.__record_decorator.name, owner.__record_decorator.options
        else
          target
        end
      end

      def decorate(target, name = nil, options = {})
        return target if defined?(Jbuilder) && Jbuilder === target
        return target if target.nil?

        if target.is_a?(ActiveRecord::Base)
          if target.respond_to?(:__record_decorator)
            return target
          else
            target.extend RecordDecorator::Marker
            target.__record_decorator = OpenStruct.new(name: name, options: options)
          end
        end

        if target.is_a?(Array)
          target.each do |record|
            decorate record, name
          end
        elsif defined?(ActiveRecord) && target.is_a?(ActiveRecord::Relation) && !target.is_a?(RecordDecorator::RelationDecorator)
          target.extend RecordDecorator::Marker
          target.__record_decorator = OpenStruct.new(name: name, options: options)
          # don't call each nor to_a immediately
          if target.respond_to?(:records)
            # Rails 5.0
            target.extend RecordDecorator::RelationDecorator
          else
            # Rails 3.x and 4.x
            target.extend RecordDecorator::RelationDecoratorLegacy
          end
        else
          decorator = decorator_for target, name
          puts "Found decorator: '#{decorator}'"
          return target unless decorator
          target.extend decorator unless target.is_a? decorator
        end
      end

      private

      def decorator_for(target, name)
        module_name = "#{target.class.name}::AddOns::#{name ? name.to_s.camelize : 'Decorator'}"
        puts "Search for decorator: '#{module_name}'"
        _const_get(module_name)
      end

      def _const_get(const)
        const.safe_constantize
      end
    end
  end

  module Marker
    def self.extended base
      base.singleton_class.send(:attr_accessor, :__record_decorator)
    end
  end

  module RelationDecoratorLegacy
    def to_a
      super.tap do |arr|
        RecordDecorator::Decorator.decorate arr, __record_decorator.name,  __record_decorator.options
      end
    end
  end

  module RelationDecorator
    def records
      super.tap do |arr|
        RecordDecorator::Decorator.decorate arr, __record_decorator.name,  __record_decorator.options
      end
    end
  end
end
