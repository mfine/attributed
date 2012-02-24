require "test_helper"

describe Attributed::Attribute do

  it "unique service_name, name, entity_name" do
    service_name, name, entity_name = uuid, uuid, uuid
    lambda { Attributed::Attribute.create(service_name: service_name, name: name, entity_name: entity_name) }.must_be_silent
    lambda { Attributed::Attribute.create(service_name: service_name, name: name, entity_name: entity_name) }.must_raise Sequel::DatabaseError
    Attributed::Attribute.find(service_name: service_name, name: name, entity_name: entity_name).wont_be_nil
  end

  it "can't find deleted entry" do
    service_name, name, entity_name = uuid, uuid, uuid
    Attributed::Attribute.create(service_name: service_name, name: name, entity_name: entity_name)
    Attributed::Attribute.find(service_name: service_name, name: name, entity_name: entity_name).wont_be_nil
    Attributed::Attribute.find_and_delete(service_name: service_name, name: name, entity_name: entity_name)
    Attributed::Attribute.find(service_name: service_name, name: name, entity_name: entity_name).wont_be_nil
    Attributed::Attribute.find(deleted_at: nil, service_name: service_name, name: name, entity_name: entity_name).must_be_nil
    Attributed::Attribute.find_or_create(service_name: service_name, name: name, entity_name: entity_name)
    Attributed::Attribute.find(deleted_at: nil, service_name: service_name, name: name, entity_name: entity_name).wont_be_nil
  end

  it "add and remove entries" do
    datas = [ { service_name: uuid, name: uuid, entity_name: uuid },
              { service_name: uuid, name: uuid, entity_name: uuid },
              { service_name: uuid, name: uuid, entity_name: uuid } ]
    lambda { Attributed::Attribute.on(datas) }.must_be_silent
    datas.each do |data|
      Attributed::Attribute.find(data.merge(deleted_at: nil)).wont_be_nil
    end
    lambda { Attributed::Attribute.off(datas) }.must_be_silent
    datas.each do |data|
      Attributed::Attribute.find(data.merge(deleted_at: nil)).must_be_nil
    end
  end

  it "Filtering selectively" do
    service_name_1, service_name_2, service_name_3 = uuid, uuid, uuid
    name_1, name_2, name_3 = uuid, uuid, uuid
    entity_name_1, entity_name_2, entity_name_3 = uuid, uuid, uuid
    datas = []
    [service_name_1, service_name_2, service_name_3].each do |service_name|
      [name_1, name_2, name_3].each do |name|
        [entity_name_1, entity_name_2, entity_name_3].each do |entity_name|
          datas << { service_name: service_name, name: name, entity_name: entity_name }
        end
      end
    end
    lambda { Attributed::Attribute.on(datas) }.must_be_silent
    [service_name_1, service_name_2, service_name_3].each do |service_name|
      Attributed::Attribute.filter(service_name: service_name).count.must_be :==, 9
      [name_1, name_2, name_3].each do |name|
        Attributed::Attribute.filter(service_name: service_name, name: name).count.must_be :==, 3
        [entity_name_1, entity_name_2, entity_name_3].each do |entity_name|
          Attributed::Attribute.filter(service_name: service_name, name: name, entity_name: entity_name).count.must_be :==, 1
        end
      end
    end
    datas.each do |data|
      Attributed::Attribute.on?(data).must_equal([data])
    end
  end

  it "yo" do
    service_name_1, service_name_2, service_name_3 = uuid, uuid, uuid
    name_1, name_2, name_3 = uuid, uuid, uuid
    entity_name_1, entity_name_2, entity_name_3 = uuid, uuid, uuid
    datas = []
    [service_name_1, service_name_2, service_name_3].each do |service_name|
      [name_1, name_2, name_3].each do |name|
        [entity_name_1, entity_name_2, entity_name_3].each do |entity_name|
          datas << { service_name: service_name, name: name, entity_name: entity_name }
          Attributed::Attribute.on([datas.last])
        end
      end
    end
    Attributed::Attribute.find_since(0, {}).each do |entry|
      puts entry.inspect
      puts entry.since
    end
    1 / 0
  end

end
