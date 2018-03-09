class Point < ApplicationRecord
  default_scope { order(number: :asc) }
end
