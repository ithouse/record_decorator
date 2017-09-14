require 'rails'
require 'record_decorator/decorate'

module RecordDecorator
  class Railtie < ::Rails::Railtie
    initializer 'record_decorator' do
      ActiveRecord::Associations::Association.prepend RecordDecorator::AssociationDecorate
      ActiveRecord::Base.include RecordDecorator::BaseDecorate
      ActiveRecord::Relation.include RecordDecorator::RelationDecorate
    end
  end
end
