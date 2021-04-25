class PriceCalculator
  INVENTORY = {
    milk: {
      sale: {
        on: true,
        quantity: 2,
        discounted_price: 5
      },
      price: 3.97
    },
    bread: {
      sale: {
        on: true,
        quantity: 3,
        discounted_price: 6
      },
      price: 2.17
    },
    banana: {
      sale: {
        on: false,
      },
      price: 0.99
    },
    apple: {
      sale: {
        on: false,
      },
      price: 0.89
    }
  }.freeze

  # return the pricing details of individual items.
  def self.item_pricing item_name, quantity
    response = {
      success: true
    }
    inventory_item = INVENTORY[item_name.downcase.to_sym]
    if inventory_item
      total_price = total_discount = 0
      inventory_item_price = inventory_item[:price]
      if inventory_item[:sale][:on]
        # means this item is on sale and available at discounted price.
        slot_size = inventory_item[:sale][:quantity]
        slot_price = inventory_item[:sale][:discounted_price]
        # distributing quantities purchased as per the quantities on sale.
        slots_purchased_at_discount = (quantity / slot_size).to_i
        purchased_quantity_at_orignal_price = (quantity % slot_size)
        total_discount = (slots_purchased_at_discount * ((slot_size * inventory_item_price) - slot_price))
        total_price = (slots_purchased_at_discount * slot_price) + (purchased_quantity_at_orignal_price * inventory_item_price)
      else
        total_price = (inventory_item_price * quantity)
        total_discount = 0
      end
      response[:data] = {
        total_price: total_price.round(2),
        discounted_price: total_discount.round(2)
      }
    else
      response[:success] = false
    end
    response
  end

  # generate the final bill of all the purchased items.
  def self.generate_bill purchased_items
    puts "\n"
    puts "Item     Quantity      Price"
    puts "---------------------------------"
    total_price = discounted_price = 0
    purchased_items.each do |key, value|
      puts "#{key}     #{value[:quantity]}      $#{value[:price]}"
      total_price += value[:price]
      discounted_price += value[:discounted_price]
    end
    puts "\n"
    puts "Total price : $#{total_price}"
    puts "You saved $#{discounted_price} today."
  end

  # calculate price for all the items purchased by the customer.
  def calculate_price items
    purchased_items = {}
    items_out_of_stock = []
    # adding quantites for individual item purchase.
    items.each do |item|
      item = item.downcase.strip()
      if purchased_items[item]
        # means multiple quantity for this item are purchased.
        purchased_items[item][:quantity] += 1
      else
        purchased_items[item] = {
          quantity: 1
        }
      end
    end
    # adding pricing as per item name.
    purchased_items.each do |key, value|
      response = PriceCalculator.item_pricing key, value[:quantity]
      if response[:success]
        item_pricing_data = response[:data]
        purchased_items[key].merge!({
          price: item_pricing_data[:total_price],
          discounted_price: item_pricing_data[:discounted_price]
        })
      else
        items_out_of_stock.push(key)
      end
    end
    puts "\nOUT OF STOCK ITEMS: #{items_out_of_stock.join(', ')}"  unless items_out_of_stock.empty?
    items_out_of_stock.map{|out_of_stock_item| purchased_items.delete(out_of_stock_item)}
    # generate the final bill for the customer.
    PriceCalculator.generate_bill purchased_items unless purchased_items.empty?
  end
end

if __FILE__ == $0
  puts "Please enter all the items purchased separated by a comma"
  items = gets.chomp.split(',')
  shopping = PriceCalculator.new
  shopping.calculate_price items
end
