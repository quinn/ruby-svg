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

  module Processing
    def self.included cls
      cls.class_eval do
        attr_accessor :rp, :shapes, :polygon, :current_style
      end
    end
 
    def to_svg
      svg = SVG.new width, height
      shapes.each{|s| svg.scripts << s}
      svg
    end
    
    def save_svg_file file_counter = 0, filename = "#{title}-#{file_counter}.svg"
      dir = "./svg_files/"
      filepath = dir + filename

      if File.exists? filepath
        save_svg_file file_counter += 1
      else
        File.open(filepath,'w') << to_svg.to_s
      end
    end
    
    def reset_svg
      @shapes = []
    end
    
    def apply_styles shape
      shape.style = current_style if current_style
      shape
    end
    
    def add_to_shapes shape
      @shapes ||= []
      shapes << shape
    end
    
    # processing API
    def begin_shape
      @polygon = SVG::Polygon.new
      super
    end
  
    def vertex *args
      polygon.vertex *args
      super
    end
  
    def end_shape idk='lolk'
      add_to_shapes apply_styles(polygon)
      @polygon = nil
      super
    end

    def ellipse x,y,w,h
      add_to_shapes apply_styles(SVG::Ellipse.new(x,y, w/2, h/2))
      super
    end
    
    def fill *args
      self.current_style = SVG::Style.new
      
      current_style.fill = "rgb(#{args[0]}, #{args[1]}, #{args[2]})"
      
      if args[3]
        current_style.fill_opacity = (args[3]/255.0)
      else            
        current_style.fill_opacity = 1.0
      end
      
      super
    end
  end
end

class Processing::App
  def with_svg &blk
    instance_eval &blk
    SVG.from_processing self, &blk
  end
end