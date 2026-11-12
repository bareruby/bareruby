# frozen_string_literal: true

class Numeric
  include Comparable

  # rubocop:disable-next Style/NumericPredicate -- this defines positive? itself, so writing positive? here would call itself
  def positive? = self > 0

  # rubocop:disable-next Style/NumericPredicate -- this defines negative? itself, so writing negative? here would call itself
  def negative? = !!(self < 0)

  # rubocop:disable-next Style/NumericPredicate -- this defines zero? itself, so writing zero? here would call itself
  def zero? = !!(self == 0)

  def integer? = false

  def finite? = true

  # rubocop:disable-next Naming/PredicateMethod, Style/ReturnNilInPredicateMethodDefinition -- infinite? returns nil for a finite value, as CRuby does
  def infinite? = nil
end
