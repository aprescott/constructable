# Constructable [![Build Status](http://travis-ci.org/mkorfmann/constructable.png)](http://travis-ci.org/mkorfmann/constructable)

Provides a powerful class macro for defining and configuring constructable attributes of a class.


## Basic usage

Define your class like this:

```ruby
require 'constructable'
class ProgrammingLanguage
  constructable :creator, :name
end
```

Then you can construct objects by providing a hash as the last argument
to ```ProgrammingLanguage.new``` like this:

```ruby
ruby = ProgrammingLanguage.new(name: 'Ruby', creator: 'Yukihiro Matsumoto')
```

The object ```ruby``` will now have the instance variables ```@name``` and
```@creator``` set to ```'Ruby'``` and ```'Yukihiro Matsumoto'```.


## Setters, Getters

You can define your constructable attributes as readable, writable or
both:

```ruby
class Train
  constructable :speed, readable: true
  constructable :next_stop, writable: true
  constructable :location, accessible: true
end

orient_express = Train.new(speed: 100)
orient_express.speed
#=> 100

orient_express.next_stop = 'Bucarest'
# @next_stop == "Bucarest"

orient_express.next_stop
# raises NoMethodError

orient_express.location = 'Budapest'
orient_express.location
#=> 'Budapest'
```


## Does not break initialize behaviour

You can use initialize just like you'd normally do:

```ruby
class Animal
  constructable [:biological_class, readable: true]
  attr_reader :name

  GuessBiologicalClass = { ['Pig', 'Cow', 'Whale'] => 'Mammal', [ 'Turtle', 'Caiman' ] => 'Reptile' }

  def initialize(name, options = {})
    @name = name
    @biological_class = GuessBiologicalClass.find { |animals,_| animals.include?(name) }.last if options[:guess_biological_class]
  end
end

rhinocerus = Animal.new('Rhinocerus', biological_class: 'Mammal')
rhinocerus.biological_class
#=> 'Mammal'

turtle = Animal.new('Turtle', guess_biological_class: true)
turtle.biological_class
#=> 'Reptile'
```


## Required attributes

```ruby
class Holidays
  constructable :when, required: true
end

summer_holidays = Holidays.new
# raises AttributeError, ':when is a required attribute'
```

## Convert your attributes

You can pass a converter as an option for a constructable attribute,
so before attributes are set, their values get converted to the return
value of the proc, you provided:

```ruby
class Box
  constructable :width, :height, converter: ->(value) { value.to_f * 100 }
end

small_box = Box.new(width: '1.40', height: '2.40')
small_box.width
#=> 140
small_box.height
#=> 240
```


## Default values

You can also specify, which values your constructable attributes are set
to by default:

```ruby
class Framework
  constructable :opinionated, default: ->{true}
end

rails = Framework.new
rails.opinionated
#=> true

```


## Redefining setters and getters

You can redefine the setters and getters provided by the constructable
macro and still get all the validations and stuff by calling ```super```:

```ruby
class Song
  constructable :length, accessible: true, required: true


  def length=(length)
    case length
    when /(\d{,2}):(\d{,2})/
      @length = $1.to_i * 60 + $2.to_i
    else
     super
    end
  end
end

song = Song.new(length: 190)
#=> #<Song:0x000001010ea040 @length=190>

song.length = '1:30'
song.length
#=> 90

song.length = nil
# raises AttributeError, ':length is a required attribute'

song = Song.new(name: 'Aaron', length: 190)
#=> #<Song:0x0x00000100941528 @length=190 @name="Aaron" @name_history=["Aaron"]>
```

## constructable\_attributes method

You can get all the constructable attributes and their values of your class as a hash,
by calling the ```constructable_attributes``` method from within an instance
of your class:

```ruby
class Gadget
  constructable :fancyness, :name, :price
end

iphone_4 = Gadget.new(fancyness: 1.0/0, name: 'Iphone 4', price: 1.0/0)
iphone_4.constructable_attributes
#=> { :fancyness => Infinity, :name => "Iphone 4", :price => Infinity }
```

## Modules

### WARNING

The constructable macro also works for modules(not for themself, but for
the classes, you include them) but it will define the 'included' hook.
So if you want to use the 'included' hook yourself, you either need to
around alias it or to use another gem. I tried some things, but it is
impossible, to provide all the magic of this gem, without defining
the 'included' macro. I thought about getting rid of some of the magic,
but this would infer with my initial intention, to provide an easy way
to make constructable classes. If someone has a nice idea, how to solve
this problem elgantly, please contact me!

## Copyright
Copyright (c) 2011 Manuel Korfmann. See LICENSE.txt for
further details.

