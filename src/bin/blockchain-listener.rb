#!/usr/bin/env ruby
# -*- mode: ruby -*-

require_relative '../lib/transaction_stream'

DB_CONFIG = {}

stream = TransactionStream.new
stream.collect
