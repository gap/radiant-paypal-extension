class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.string :name
      t.integer :price_in_cents
      t.integer :quantity
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
