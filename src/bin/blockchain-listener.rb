#!/usr/bin/env ruby
# -*- mode: ruby -*-

require_relative '../lib/transaction_stream'

DB_CONFIG = {}

stream = new TransactionStream
stream.collect
