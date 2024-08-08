require 'chunky_png'

class EscPosPrinterSize
  INCH_TO_MM = 25.4

  attr_reader :printer_dpi, :printer_width_mm, :printer_nbr_characters_per_line,
              :printer_width_px, :printer_char_size_width_px

  def initialize(printer_dpi:, printer_width_mm:, printer_nbr_characters_per_line:)
    @printer_dpi = printer_dpi
    @printer_width_mm = printer_width_mm
    @printer_nbr_characters_per_line = printer_nbr_characters_per_line
    printing_width_px = mm_to_px(@printer_width_mm)
    @printer_width_px = printing_width_px + (printing_width_px % 8)
    @printer_char_size_width_px = printing_width_px / @printer_nbr_characters_per_line
  end

  # Convert from millimeters to pixels
  def mm_to_px(mm_size)
    (mm_size * @printer_dpi / INCH_TO_MM).round
  end

  # Convert a PNG image to ESC/POS bytes
  def bitmap_to_bytes(png_data, gradient)
    png = ChunkyPNG::Image.from_blob(png_data)
    bitmap_width = png.width
    bitmap_height = png.height
    max_width = @printer_width_px
    max_height = 256

    if bitmap_width > max_width
      bitmap_height = (bitmap_height.to_f * max_width / bitmap_width).round
      bitmap_width = max_width
    end
    if bitmap_height > max_height
      bitmap_width = (bitmap_width.to_f * max_height / bitmap_height).round
      bitmap_height = max_height
    end

    png = png.resize(bitmap_width, bitmap_height, :nearest_neighbor)

    # Convert PNG to ESC/POS bytes
    EscPosPrinterCommands.bitmap_to_bytes(png, gradient)
  end
end