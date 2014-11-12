#!/usr/bin/env ruby
# -*- mode: ruby -*-

require_relative '../lib/app'
require_relative '../lib/transaction_stream'

App.configure!

stream = TransactionStream.new
while true do
  stream.collect
end
