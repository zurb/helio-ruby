# frozen_string_literal: true

module Helio
  class CustomerList < APIResource
    extend Helio::APIOperations::Create
    include Helio::APIOperations::Delete
    include Helio::APIOperations::Save
    extend Helio::APIOperations::List
    extend Helio::APIOperations::NestedResource

    OBJECT_NAME = "customer_list"

    save_nested_resource :participant
    nested_resource_class_methods :participant,
                                  operations: %i[create retrieve update delete list]

    def add_participant(params, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Participant.create(params.merge(customer_list_id: id), opts)
    end

    def participants(params = {}, opts = {})
      resp, opts = request(:get, resource_url + "/participants", params, Util.normalize_opts(opts))
      Util.convert_to_helio_object(resp.data, opts)
    end
  end
end
