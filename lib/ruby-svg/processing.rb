# Replicating the Processing API in svg. 

module SVG
  def from_processing &blk
    processing = ProcessingAPI.new.instance_eval blk
    processing.to_svg
  end
end


class Polygon
  def initialize(points=[])
    super()
    @points = points
  end
  
  def vertex x,y
    points << "#{x}, #{y}"
  end
end

class ProcessingAPI
  attr_accessor :shapes, :polygon
  
  def initialize
    @shapes = []
  end
  
  def begin_shape
    @polygon = Polygon.new
  end
  
  def vertex *args
    polygon.vertex *args
  end
  
  def end_shape
    shapes << polygon
    @polygon = nil
  end
end
