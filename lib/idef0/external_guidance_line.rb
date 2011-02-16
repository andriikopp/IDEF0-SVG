require_relative 'point'
require_relative 'labels'
require_relative 'external_line'

module IDEF0

  class ExternalGuidanceLine < ExternalLine

    def self.make_line(source, target)
      source.top_side.each do |name|
        yield(new(source, target, name)) if target.top_side.expects?(name)
      end
    end

    def initialize(*args)
      super
      clear(@target.top_side, 20)
    end

    def attach
      @target_anchor = target.top_side.attach(self)
    end

    def bounds(bounds)
      add_clearance_from(@target.top_side, y1 - bounds.y1 + 40)
    end

    def avoid(lines)
      while lines.any?{ |other| label.overlapping?(other.label) } do
        add_clearance_from(@target.top_side, -20)
      end
    end

    def x1
      target_anchor.x
    end

    def y1
      y2 - clearance_from(@target.top_side)
    end

    def x2
      x1
    end

    def left_edge
      label.left_edge
    end

    def right_edge
      label.right_edge
    end

    def label
      CentredLabel.new(@name, Point.new(x1, y1+20-5))
    end

    def clearance_group(side)
      case
      when @target.top_side
        2
      else
        super
      end
    end

    def to_svg
      <<-XML
<line x1='#{x1}' y1='#{y1+20}' x2='#{x2}' y2='#{y2}' stroke='black' />
#{svg_down_arrow(x2, y2)}
#{label.to_svg}
XML
    end

  end

end