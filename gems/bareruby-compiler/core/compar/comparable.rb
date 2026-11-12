# frozen_string_literal: true

module Comparable
  # rubocop:disable-next Style/NumericPredicate -- Comparable reads the sign of <=> with < and > as CRuby's rb_cmpint does, so the result need not be an Integer
  def <(other) = (self <=> other) < 0

  # rubocop:disable-next Style/NumericPredicate, Style/InverseMethods -- a result that is neither positive nor negative counts as 0, as in CRuby's rb_cmpint
  def <=(other) = !((self <=> other) > 0)

  # rubocop:disable-next Style/NumericPredicate -- Comparable reads the sign of <=> with < and > as CRuby's rb_cmpint does, so the result need not be an Integer
  def >(other) = (self <=> other) > 0

  # rubocop:disable-next Style/NumericPredicate, Style/InverseMethods -- a result that is neither positive nor negative counts as 0, as in CRuby's rb_cmpint
  def >=(other) = !((self <=> other) < 0)
end
