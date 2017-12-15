module Helio
  class Participant < APIResource
    include Helio::APIOperations::Save
    include Helio::APIOperations::Delete
    extend Helio::APIOperations::List

    OBJECT_NAME = "participant".freeze
  end
end
