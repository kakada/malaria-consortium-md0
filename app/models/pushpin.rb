class Pushpin
  include Magick

  def initialize(width, height)
    @width = width
    @height = height
    @center_x = width / 2
    @center_y = height / 2
  end

  def image(options = {})
    image = Image.new(@width, @height) { self.format = 'jpeg' }

    @draw = Draw.new
    draw_center
    draw_bar -options[:left].to_f, 'red'
    draw_bar options[:right].to_f, 'blue'
    @draw.draw image

    image
  end

  def self.type
    'image/jpg'
  end

  private

  def draw_center
    @draw.fill = 'black'
    @draw.line @center_x, 0, @center_x, (@height - 1)
  end

  def draw_bar(value, color)
    @draw.fill color
    @draw.rectangle @center_x, (@center_y - 4), (@center_x - scale(value)), (@center_y + 3)
  end

  def scale(value)
    value * @center_x / 100.0
  end

end
