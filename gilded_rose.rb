def update_quality(items)
  items.each do |item|
    GildedRoseItem(item).new_day
  end
end

def GildedRoseItem(item)
  gilded_rose_item = GildedRoseItem.new(item)

  if item.name.start_with?("Conjured")
    gilded_rose_item.extend QualityChange::DoublyDecreasing
  elsif item.name.start_with?("Sulfuras")
    gilded_rose_item.extend QualityChange::None
    gilded_rose_item.extend MaximumQuality::Raised
    gilded_rose_item.extend Aging::None
  elsif item.name.start_with?("Backstage passes")
    gilded_rose_item.extend QualityChange::BackstagePass
  elsif item.name == "Aged Brie"
    gilded_rose_item.extend QualityChange::Increasing
  end

  gilded_rose_item
end

module QualityChange
  module Decreasing
    def updated_quality(quality, sell_in)
      quality - 1
    end
  end

  module DoublyDecreasing
    def updated_quality(quality, sell_in)
      quality - 2
    end
  end

  module Increasing
    def updated_quality(quality, sell_in)
      quality + 1
    end
  end

  module None
    def updated_quality(quality, sell_in)
      quality
    end
  end

  module BackstagePass
    def updated_quality(quality, sell_in)
      return 0 if sell_in < 0

      new_quality = quality + 1

      new_quality += 1 if sell_in < 10
      new_quality += 1 if sell_in < 5

      new_quality
    end
  end
end

module MaximumQuality
  module Normal
    def maximum_quality
      50
    end
  end

  module Raised
    def maximum_quality
      80
    end
  end
end

module Aging
  module Normal
    def updated_sell_in(sell_in)
      sell_in - 1
    end
  end

  module None
    def updated_sell_in(sell_in)
      sell_in
    end
  end
end

GildedRoseItem = Struct.new(:item) do
  include QualityChange::Decreasing
  include MaximumQuality::Normal
  include Aging::Normal

  def new_day
    update_sell_in
    update_quality
  end

  private

  def quality
    item.quality
  end

  def sell_in
    item.sell_in
  end

  def overdue?
    sell_in < 0
  end

  def update_sell_in
    item.sell_in = updated_sell_in(sell_in)
  end

  def update_quality
    (overdue? ? 2 : 1).times do
      item.quality = clamp(updated_quality quality, sell_in)
    end
  end

  def clamp(value)
    [[value, 0].max, maximum_quality].min
  end
end


# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

