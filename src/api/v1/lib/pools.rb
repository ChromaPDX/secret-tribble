require_relative '../../../lib/pool.rb'

doc '/v1/pools'
get '/v1/pools.json' do
  unless require_token!
    invalid_credentials!
    return
  end
  
  pool_id = params[:pool_id]

  d = Pool.new( pool_id )
  if d.load!
    @out = d
  else
    status 404
    @errors.add("No pool found with pool_id #{pool_id}")
  end
end

post '/v1/pools.json' do
  unless require_token!
    invalid_credentials!
    return
  end
  
  raw = JSON.parse( params[:pool] )
  d = Pool.new( raw['pool_id'] )
  raw['splits'].each do |account_id, split_pct|
    d.split!( account_id, BigDecimal.new( split_pct.to_s ) )
  end

  if d.valid?
    d.save
    @out = d
  else
    d.errors.each { |de| @errors.add( de ) }
  end
end
