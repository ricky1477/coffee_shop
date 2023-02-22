class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true
  after_save :compute_discount
  after_save :computer_order_total

  def number_of_items
    return @number_of_items if @number_of_items
    @number_of_items = 0
    self.order_items.includes(:item).each do |order_item|
      @number_of_items += order_item.quantity
    end
    @number_of_items
  end

  def compute_discount
    return @discount if @discount
    byebug
    if number_of_items > 1
      @discount = 0.03
    elsif number_of_items > 5
      @discount = 0.05
    else
      @discount = 0
    end
    self.update_column(:discount, @discount)
    @discount
  end

  def compute_order_total
    return @total if @total
    @total = 0.0
    self.order_items.includes(:item).each do |order_item|
      @total += (order_item.item.price * order_item.quantity).to_f
    end
    # Apply discount
    @total = (1-compute_discount)*@total

    self.update_column(:order_total, @total)
    @total
  end

end
