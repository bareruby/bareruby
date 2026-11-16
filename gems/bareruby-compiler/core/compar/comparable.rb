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

  # rubocop:disable-next Style/NumericPredicate, Style/InverseMethods -- a result that is neither positive nor negative counts as 0, as in CRuby's rb_cmpint
  def between?(min, max) = !((self <=> min) < 0) && !((self <=> max) > 0)

  def ==(other)
    return true if equal?(other)

    order = self <=> other
    return false if order.nil?

    # rubocop:disable-next Style/NumericPredicate -- the result of <=> is compared with 0 as CRuby's cmp_equal does, so it need not be an Integer
    order == 0
  end
end
