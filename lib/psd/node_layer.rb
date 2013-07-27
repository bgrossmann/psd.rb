class PSD::Node
  class Layer < PSD::Node
    include PSD::Node::LockToOrigin

    attr_reader :layer

    def initialize(layer)
      @layer = layer
      layer.node = self
      @children = []
    end

    (PROPERTIES + [:text, :ref_x, :ref_y]).each do |meth|
      define_method meth do
        @layer.send(meth)
      end

      define_method "#{meth}=" do |val|
        @layer.send("#{meth}=", val)
      end
    end

    def method_missing(method, *args, &block)
      layer.send(method, *args, &block)
    end

    def translate(x=0, y=0)
      @layer.translate x, y
    end

    def scale_path_components(xr, yr)
      @layer.scale_path_components(xr, yr)
    end

    def hide!
      # TODO actually mess with the blend modes instead of
      # just putting things way off canvas
      return if @hidden_by_kelly
      translate(100000, 10000)
      @hidden_by_kelly = true
    end

    def show!
      if @hidden_by_kelly
        translate(-100000, -10000)
        @hidden_by_kelly = false
      end
    end

    def to_hash
      super.merge({
        type: :layer,
        text: @layer.text,
        ref_x: @layer.reference_point.x,
        ref_y: @layer.reference_point.y
      })
    end

    def document_dimensions
      @parent.document_dimensions
    end
  end
end