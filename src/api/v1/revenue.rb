doc '/v1/revenue'

get '/v1/revenue.json' do
  if require_token!
    revenue_id = params[:revenue_id]
    pool_id = params[:pool_id]

    if !revenue_id and !pool_id
      @errors.add("Please specify a pool_id or revenue_id")
      return
    end
    
    if revenue_id
      r = Revenue.with_revenue_id( revenue_id )
      @out = r
      return
    end

    if pool_id
      rs = Revenue.with_account_pool( @account.account_id, pool_id )
      @out = rs
      return
    end
  end

  invalid_credentials!
end

post '/v1/revenue.json' do
  if require_token!
    pool_id = params[:pool_id]
    amount = params[:amount]
    currency = params[:currency]

    @errors.add("Please specify a pool_id") unless pool_id
    @errors.add("Please specify an amount") unless amount
    @errors.add("Please specify a currency") unless currency

    return unless @errors.empty?

    r = Revenue.new( pool_id: pool_id, amount: BigDecimal.new(amount), currency: currency )
    unless r.valid?
      r.errors.each { |r| @errors.add r }
      return
    end

    r.create!
    @out = r
    return
  end

  invalid_credentials!
end
