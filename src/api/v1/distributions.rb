require_relative '../../lib/distribution.rb'

doc '/v1/distributions'
get '/v1/distributions.json' do
  pool_id = params[:pool_id]
  d = Distribution.new( pool_id )
  if d.load!
    @out = d
  else
    status 404
    @errors.add("No distribution found with pool_id #{pool_id}")
  end
end

post '/v1/distributions.json' do
  raw = JSON.parse( params[:distribution] )
  d = Distribution.new( raw['pool_id'] )
  raw['splits'].each do |account_id, split_pct|
    d.split!( account_id, BigDecimal.new( split_pct ) )
  end

  if d.valid?
    d.save
    @out = d
  else
    d.errors.each { |de| @errors.add( de ) }
  end
end
