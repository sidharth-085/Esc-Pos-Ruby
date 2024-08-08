class PrinterTextParserImg
  # Convert Drawable instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, drawable)
    if drawable.is_a?(BitmapDrawable)
      bitmap_to_hexadecimal_string(printer_size, drawable.bitmap)
    else
      ""
    end
  end

  # Convert Drawable instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, drawable, gradient)
    if drawable.is_a?(BitmapDrawable)
      bitmap_to_hexadecimal_string(printer_size, drawable.bitmap, gradient)
    else
      ""
    end
  end

  # Convert BitmapDrawable instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, bitmap_drawable)
    bitmap_to_hexadecimal_string(printer_size, bitmap_drawable.bitmap)
  end

  # Convert BitmapDrawable instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, bitmap_drawable, gradient)
    bitmap_to_hexadecimal_string(printer_size, bitmap_drawable.bitmap, gradient)
  end

  # Convert Bitmap instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, bitmap)
    bitmap_to_hexadecimal_string(printer_size, bitmap, true)
  end

  # Convert Bitmap instance to a hexadecimal string of the image data.
  def self.bitmap_to_hexadecimal_string(printer_size, bitmap, gradient)
    bytes_to_hexadecimal_string(printer_size.bitmap_to_bytes(bitmap, gradient))
  end

  # Convert byte array to a hexadecimal string of the image data.
  def self.bytes_to_hexadecimal_string(bytes)
    bytes.map { |byte| byte.to_s(16).rjust(2, '0') }.join
  end

  # Convert hexadecimal string of the image data to bytes ESC/POS command.
  def self.hexadecimal_string_to_bytes(hex_string)
    [hex_string].pack('H*').bytes
  end

  attr_reader :length, :image

  # Create new instance of PrinterTextParserImg.
  def initialize(printer_text_parser_column, text_align, hexadecimal_string)
    self.class.new(printer_text_parser_column, text_align, self.class.hexadecimal_string_to_bytes(hexadecimal_string))
  end

  # Create new instance of PrinterTextParserImg.
  def initialize(printer_text_parser_column, text_align, image)
    printer = printer_text_parser_column.line.text_parser.printer

    byte_width = (image[4] & 0xFF) + ((image[5] & 0xFF) * 256)
    width = byte_width * 8
    height = (image[6] & 0xFF) + ((image[7] & 0xFF) * 256)
    nbr_byte_diff = ((printer.printer_width_px - width) / 8.0).to_i
    nbr_white_byte_to_insert = 0

    case text_align
    when PrinterTextParser::TAGS_ALIGN_CENTER
      nbr_white_byte_to_insert = (nbr_byte_diff / 2.0).round
    when PrinterTextParser::TAGS_ALIGN_RIGHT
      nbr_white_byte_to_insert = nbr_byte_diff
    end

    if nbr_white_byte_to_insert > 0
      new_byte_width = byte_width + nbr_white_byte_to_insert
      new_image = EscPosPrinterCommands.init_gsv0_command(new_byte_width, height)
      height.times do |i|
        new_image[(new_byte_width * i + nbr_white_byte_to_insert + 8), byte_width] = image[(byte_width * i + 8), byte_width]
      end
      @image = new_image
    else
      @image = image
    end

    @length = ((byte_width * 8) / printer.printer_char_size_width_px.to_f).ceil
  end

  # Get the image width in char length.
  def length
    @length
  end

  # Print image
  def print(printer_socket)
    printer_socket.print_image(@image)
    self
  end
end