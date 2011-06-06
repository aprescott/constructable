require 'helper'
include Constructable
describe 'Attribute' do
  describe 'name' do
    it 'returns the name' do
      attribute = Attribute.new(:attribute)
      assert_equal :attribute, attribute.name
    end
  end

  describe 'ivar_symbol' do
    it 'should return @<name>' do
      attribute = Attribute.new(:foo)
      assert_equal :@foo, attribute.ivar_symbol
    end
  end

  describe 'process' do
    it 'should raise nothing if no attributes are specified' do
      attribute = Attribute.new(:foo)
      assert_equal 'bar', attribute.process({foo: 'bar'})
    end

    describe 'required attribute' do
      it 'should raise an AttributeError if required is set to true' do
        attribute = Attribute.new(:foo, required: true)
        begin
          attribute.process(bar: 'blab')
        rescue Exception => e
          assert AttributeError === e
          assert_equal ':foo is a required attribute', e.message
        else
          assert false, 'AttributeError was not raised'
        end
      end
    end

    describe 'attribute is neither required nor provided' do
      it 'does not check for further requirements' do
        attribute = Attribute.new(:foo, validate_type: Integer)
        refute_raises do
          attribute.process({})
        end
      end
    end

    describe 'validator' do
      it 'should raise an AttributeError if the validator doesn\'t pass' do
        attribute = Attribute.new(:foo, validate: ->(number) { number < 5 })
        begin
          attribute.process(foo: 6)
        rescue Exception => e
          assert AttributeError === e, "[#{e.class},#{e.message}] was not expected"
          assert_equal ':foo did not pass validation', e.message
        else
          assert false, 'AttributeError was not raised'
        end
      end
    end

    describe 'validate_type check' do
      it 'should raise an AttributeError if the value has not the wanted validate_type' do
        attribute = Attribute.new(:foo, validate_type: Integer)
        begin
          attribute.process(foo: 'notanumber')
        rescue Exception => e
          assert AttributeError === e, "[#{e.class},#{e.message}] was not expected"
          assert_equal ':foo is not of validate_type Integer', e.message
        else
          assert false, 'AttributeError was not raised'
        end
      end
    end

    describe 'default value' do
      it 'should be possible to provide a default value' do
        attribute = Attribute.new(:foo, default: :bar)
        assert_equal :bar, attribute.process({})
      end
    end

    describe 'convert value' do
      it 'is possible to define a converter(proc) which converts attribute values' do
        attribute = Attribute.new(:number, converter: ->(value) { value.to_i })
        assert_equal 5, attribute.process({number: '5'})
      end
    end
  end

  describe 'permission' do
    it 'should detect accessible attributes' do
      attribute = Attribute.new( :readable_and_writable, accessible: true)
      assert_equal [:reader, :writer], attribute.permissions
    end

    it 'should not be public by default' do
      attribute = Attribute.new( :test_default)
      assert_equal [] , attribute.permissions
    end

    [:writable, :readable].each do |perm|
      it "should be definable for #{perm}" do
        attribute = Attribute.new(:"#{perm}_option", perm => true)
        assert_equal [(perm[0..3] + 'er').to_sym], attribute.permissions
      end
    end
  end
end