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

  #ApiMethods = :begin_shape, :vertex, :end_shape
  module Processing
    def self.included cls
      cls.class_eval do
        attr_accessor :rp, :shapes, :polygon, :current_fill
      end
    end
  
    # def initialize rp
    #   @shapes = []
    #   @rp = rp
    # end
  
    def begin_shape
      @polygon = SVG::Polygon.new
      super
    end
  
    def vertex *args
      polygon.vertex *args
      super
    end
  
    def end_shape idk='lolk'
      shapes << polygon
      @polygon = nil
      super
    end

    def ellipse x,y,w,h
      @shapes||= []
      shapes << SVG::Ellipse.new(x,y, w/2, h/2)
      super
    end
    
    def to_svg
      svg = SVG.new width, height
      shapes.each{|s| svg.scripts << s}
      svg
    end
    
    # module Frame
    #   def self.included cls
    #   cls.class_eval do
    #     attr_accessor :svg
    #     before :draw, :setup_svg
    #     after  :draw, :log_svg
    #   
    #     def setup_svg
    #       @svg = SVG.new width, height
    #     end
    #   
    #     def log_svg
    #     
    #     end
    #   end;end;
    # end
  end
end

class Processing::App
  def with_svg &blk
    instance_eval &blk
    SVG.from_processing self, &blk
  end
end