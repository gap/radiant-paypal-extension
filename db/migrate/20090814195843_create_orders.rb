class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.text :notes
      t.integer :total_in_cents
      t.string :paypal_token
      t.string :paypal_id

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
