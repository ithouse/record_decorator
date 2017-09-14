require 'record_decorator/decorator'

module RecordDecorator
  module AssociationDecorate
    def target
      RecordDecorator::Decorator.decorate_association(owner, super)
    end
  end

  module BaseDecorate
    def decorate(name = nil, options = {})
      RecordDecorator::Decorator.decorate(self, name, options)
    end
  end

  module RelationDecorate
    def decorate(name = nil, options = {})
      RecordDecorator::Decorator.decorate(self, name, options)
    end
  end
end
