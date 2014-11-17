#!/usr/bin/env ruby
# This file sets up an environment suitable for testing. It will always use the test database. :)

require_relative '../lib/app'

# enforce the test environment
App.configure! "test"

# wipe everything out of the database
App.db_tables.each do |table|
  App.db[table].delete
end

BTC_ADDRESSES = {
  mike: "1Lh7GWvYteroTU9e18CWE1ekfHAWvNkRdo",
  marcus: "15vbQAQAnU7MmUNw47HZKLH7qRNPgPQufM",
  peat: "15cwwUajPhVXXVxoTdtj14DW12yJS6sbyr"
}

# start from scratch.
# 1: Create five users
@users = BTC_ADDRESSES.keys.map do |name|
  username = "#{name.to_s.downcase}@test.com"
  password = "password"

  user = User.create!( name.to_s )
  user.set_username_pass( username, password )
  [name, user]
end

# turn the array into a hash, with the names as keys
@users = Hash[ @users ]
puts "\nCreated Users:"
@users.each_value do |u|
  puts "  #{u.name}: #{u.user_id}"
end


# 2: Create a pool for those users
@pool = Pool.new( App.unique_id )
@pool.split! @users[:peat].user_id, BigDecimal.new("0.70")
@pool.split! @users[:mike].user_id, BigDecimal.new("0.25")
@pool.split! @users[:marcus].user_id, BigDecimal.new("0.05")
@pool.save

puts "\nCreated Pool:"
puts "  #{@pool.pool_id}"

puts "\nCreated Splits:"
@pool.splits.each do |uid,amt|
  puts "  #{uid}: %0.4f" % amt
end

# 3: Create a new project for that pool
@project = Project.new( name: "ABCDE Project", pool_id: @pool.pool_id )
@project.save!

puts "\nCreated Project:"
puts "  #{@project.name}: #{@project.project_id}"


# 4: Create an origin wallet for Bitcoin
@origin_wallet = Wallet.new(relation_id: "NO_RELATION",
                            kind: Wallet::ORIGIN_KIND,
                            currency: Wallet::BTC_CURRENCY,
                            identifier: "BTC_ORIGIN")
@origin_wallet.save!

puts "\nCreated Origin Wallet:"
puts "  #{@origin_wallet.identifier}: #{@origin_wallet.wallet_id}"

# 5: Create a revenue wallet for the pool
@revenue_wallet = Wallet.new(relation_id: @project.project_id,
                             kind: Wallet::REVENUE_KIND,
                             currency: Wallet::BTC_CURRENCY,
                             identifier: "PROJECT_BITCOIN_ADDRESS")
@revenue_wallet.save!

puts "\nCreated Project Wallet:"
puts "  #{@revenue_wallet.wallet_id}: #{@revenue_wallet.identifier}"
puts "  project_id: #{@revenue_wallet.relation_id}"

# 6: Create backer wallets for all of the users
puts "\nCreated Backer Wallets:"
@users.each do |name, u|
  wallet = Wallet.new(relation_id: u.user_id,
                      kind: Wallet::BACKER_KIND,
                      currency: Wallet::BTC_CURRENCY,
                      identifier: BTC_ADDRESSES[name])
  wallet.save!
  puts "  #{u.name} (#{u.user_id}): #{wallet.currency} - #{wallet.identifier}"
end

# 7: Insert a bunch of raw BTC transactions into the queue


TRANSACTION_COUNT = 100
puts "\nInserting #{TRANSACTION_COUNT} BTC revenue transactions ..."
msg_template = {
  currency: Wallet::BTC_CURRENCY,
  project_id: @project.project_id,
  pool_id: @pool.pool_id,
  wallet_id: @revenue_wallet.wallet_id
}

revenue_transactions = PersistentQueue.new("revenue_transactions")
TRANSACTION_COUNT.times do
  msg = msg_template.clone
  msg[:amount] = Random.new.rand(1000..100000000)
  msg[:transaction_id] = App.unique_id
  msg[:origin] = { name: "blockchain", hash: App.unique_id }, 
  revenue_transactions.push( msg )
end
