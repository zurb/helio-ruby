module Helio
  class CustomerList < APIResource
    extend Helio::APIOperations::Create
    include Helio::APIOperations::Delete
    include Helio::APIOperations::Save
    extend Helio::APIOperations::List
    extend Helio::APIOperations::NestedResource

    OBJECT_NAME = "customer_list".freeze

    save_nested_resource :participant
    nested_resource_class_methods :participant,
                                  operations: %i[create retrieve update delete list]

    # class << self
    #   alias detach_source delete_source
    # end

    def add_participant(params, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Participant.create(params.merge(participant: id), opts)
    end

  end
end
