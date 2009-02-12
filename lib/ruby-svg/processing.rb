# Replicating the Processing API in svg. 

module SVG
  def self.from_processing rp, &blk
    processing = SVG::Processing.new rp
    processing.instance_eval &blk
    processing.to_svg
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

  class Processing
    attr_accessor :rp, :shapes, :polygon
  
    def initialize rp
      @shapes = []
      @rp = rp
    end
  
    def begin_shape
      @polygon = Polygon.new
    end
  
    def vertex *args
      polygon.vertex *args
    end
  
    def end_shape idk='lolk'
      shapes << polygon
      @polygon = nil
    end
    
    def to_svg
      svg = SVG.new rp.width, rp.height
      shapes.each{|s| svg.scripts << s}
      svg
    end
  end
end

class Processing::App
  def with_svg &blk
    instance_eval &blk
    SVG.from_processing self, &blk
  end
end