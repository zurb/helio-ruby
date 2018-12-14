# frozen_string_literal: true

module Helio
  class Participant < APIResource
    extend Helio::APIOperations::Create
    include Helio::APIOperations::Delete
    include Helio::APIOperations::Save
    extend Helio::APIOperations::List

    OBJECT_NAME = "participant"
  end
end
