require_relative 'helper'
require_relative '../project'

describe Project do

  before(:all) do
    @pool = Pool.new( App.unique_id )
    @pool.split!("alice", BigDecimal.new("0.5"))
    @pool.split!("bob", BigDecimal.new("0.3"))
    @pool.split!("carol", BigDecimal.new("0.2"))
    @pool.save
  end
  
  it "should save and load" do
    project_name = "derp"
    project = Project.new( name: project_name )
    project.set_pool( App.unique_id )
    expect( project.save! ).to_not be false

    expect( project.created_at ).to_not be nil
    expect( project.project_id ).to_not be nil
    expect( project.pool_id ).to_not be nil
    
    p2 = Project.get( project.project_id )
    expect( p2.project_id ).to eq( project.project_id )
    expect( p2.created_at.to_s ).to eq(project.created_at.to_s)
    expect( p2.pool_id ).to eq(project.pool_id)
    expect( p2.name ).to eq(project.name)
  end
  
  it "should have a pool assigned to it" do
    pool_id = App.unique_id
    project = Project.new    
    project.set_pool( pool_id )

    expect( project.pool_id ).to eq(pool_id)
  end

  it "should convert to JSON" do
    p1 = Project.new( name: "derpfest" )
    p1.set_pool( App.unique_id )
    p1.save!

    p2 = Project.get( p1.project_id )
    expect( p1.to_json ).to eq( p2.to_json )
  end

  it "should have users associated with it, via pool splits" do
    p = Project.new( name: "woooot", pool_id: @pool.pool_id )
    backers = p.with_backers!
    expect( backers ).to eq( @pool.splits )
    expect( p.backers ).to eq( @pool.splits )

    j = JSON.parse( p.to_json )
    expect( j['backers'] ).to be_a(Hash)
  end

end
