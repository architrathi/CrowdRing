require File.dirname(__FILE__) + '/spec_helper'

describe Crowdring::TagFilter do
  before(:each) do
    DataMapper.auto_migrate!
  end

  it 'should be able to have many tags' do
    tag_filter = Crowdring::TagFilter.create
    pittsburgh = Crowdring::Tag.from_str('area code:412')
    chicago = Crowdring::Tag.from_str('area code:312')
    tag_filter.tags << pittsburgh
    tag_filter.tags << chicago

    tag_filter.tags.should include(Crowdring::Tag.from_str('area code:412'))
    tag_filter.tags.should include(Crowdring::Tag.from_str('area code:312'))
  end

  it 'should filter out items that dont have all of the provided tags' do
    tag_filter = Crowdring::TagFilter.create
    pittsburgh = Crowdring::Tag.from_str('area code:412')
    chicago = Crowdring::Tag.from_str('area code:312')
    tag_filter.tags << pittsburgh
    tag_filter.tags << chicago 

    item1 = double('take', tags: [pittsburgh])
    item2 = double('drop', tags: [])

    took = tag_filter.filter([item1, item2])
    took.should_not include(item1)
    took.should_not include(item2)
  end

  it 'should filter out items that dont have at least one value of every provided tag type' do
    tag_filter = Crowdring::TagFilter.create
    pittsburgh = Crowdring::Tag.from_str('area code:412')
    male = Crowdring::Tag.from_str('gender:male')

    tag_filter.tags << pittsburgh
    tag_filter.tags << male

    take_item = double('take', tags: [pittsburgh, male])
    drop_item = double('drop', tags: [male])

    took = tag_filter.filter([take_item, drop_item])
    took.should include(take_item)
    took.should_not include(drop_item)
  end

  it 'should accept all items when there are no tags specified for the filter' do
    tag_filter = Crowdring::TagFilter.create
    pittsburgh = Crowdring::Tag.from_str('area code:412')
    male = Crowdring::Tag.from_str('gender:male')

    item1 = double('item1', tags: [pittsburgh, male])
    item2 = double('item2', tags: [male])
    item3 = double('item3', tags: [])

    items = [item1, item2, item3]
    took = tag_filter.filter(items)
    took.should eq(items)
  end

  it 'should accept a single matching item' do
    tag_filter = Crowdring::TagFilter.create
    pittsburgh = Crowdring::Tag.from_str('area code:412')
    male = Crowdring::Tag.from_str('gender:male')

    tag_filter.tags << pittsburgh
    tag_filter.tags << male

    take_item = double('take', tags: [pittsburgh, male])
    drop_item = double('drop', tags: [male])

    tag_filter.accept?(take_item).should be_true
    tag_filter.accept?(drop_item).should be_false
  end

  it 'should accept a list of string tags' do
    tag_filter = Crowdring::TagFilter.create(tags: ['foo:bar', 'boo:baz'])
    tag_filter.saved?.should be_true
    tag_filter.tags.count.should eq(2)
  end

end