class Creteria
  attr_accessor :max, :min, :max_size, :min_size , :count
  attr_accessor :data

  def initialize
    @data = @data || {}
  end
  def add_record! key, value
    
    @data[key] = value
  end

  def add_records! records
    @data = @data || {}
    @data.merge(records)
  end

  def prepare!
    @max_size = 5
    @min_size = 1

    @max = -1000
    @min = 1000

    @data.each do |key,value|
      if(value > @max)
          @max = value
      end
      if(value < @min)
        @min = value
      end
    end
  end

  def cloud
    cloud = {}
    @data.each do |key, value|
      size =0
      if(@data.size == 1)
        size = @max_size
      elsif (@max == @min)
        size = 1
      else
        size = @min_size + ((@max-(@max-(value-@min)))*(@max_size-@min_size)/(@max-@min))
      end
      cloud[key] = {:value =>value, :size => size}
    end
    cloud
  end

end