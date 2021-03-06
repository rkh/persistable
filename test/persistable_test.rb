#!/usr/bin/env maglev-ruby -rubygems
require "test_helper"

class PersistableWithoutInstancesTest < Test::Unit::TestCase
  
  class ::Egg; include Persistable end
  
  def test_class_should_be_flagged_as_persistable
    assert Egg.maglev_persistable?
  end
  
end

class PersistableWithInstancesTest < Test::Unit::TestCase
  
  class ::Bacon < Struct.new(:type); include Persistable end
  
  def setup
    @soggy_bacon   =  Bacon.new "soggy"
    @crunchy_bacon =  Bacon.new "crunchy"
    @chunky_bacon  =  Bacon.new "chunky"
    @artery_cloggers = [@soggy_bacon, @crunchy_bacon, @chunky_bacon]
  end
  
  def persist_all
    @artery_cloggers.each {|bacon| bacon.persist}
  end
  
  def teardown
    Bacon.delete_all
  end
  
  def test_persistable_module_is_persistent
    assert Persistable.maglev_persistable?
  end
  
  def test_class_store_starts_empty
    assert Bacon.all.empty?
  end
  
  def test_instances_can_be_persisted
    persist_all
    breakfast = Bacon.all
    assert breakfast.size, 3
    @artery_cloggers.each {|bacon| assert breakfast.include?(bacon)}
  end
  
  def test_count_returns_number_of_persistent_instances
    @artery_cloggers.each_with_index do |bacon, i|
      bacon.persist
      assert Bacon.count, i + 1
    end
  end
  
  def test_delete_all_empties_class_store
    persist_all
    Bacon.delete_all
    assert Bacon.count, 0
  end
  
  def test_select_works_for_querying
    persist_all
    @artery_cloggers.each do |bacon|
      results = Bacon.select {|x| x.type[/#{bacon.type}/]}
      assert results.size, 1
      assert results.include?(bacon)
    end
  end
  
  def test_ask_an_instance_if_it_is_persisted
    assert @chunky_bacon.transient?
    @chunky_bacon.persist
    assert @chunky_bacon.persistent?
  end
  
  def test_instances_can_be_desisted
    @chunky_bacon.desist
    assert @chunky_bacon.transient?
  end
  
  # Module#include? shouldn't be forwarded when
  # argument.class == Module
  def test_module_include_still_works
    @soggy_bacon.persist
    assert Bacon.include? @soggy_bacon
    # When passed a module, Bacon.include? checks if 
    # the module is in its ancestry
    assert Bacon.include? Persistable
  end
  
  # Tests to check only when riding on Maglev
  if defined? Maglev
    
    def test_class_is_flagged_as_persistable
      assert Bacon.maglev_persistable?
      assert Set.maglev_persistable?
    end
    
  end
  
end