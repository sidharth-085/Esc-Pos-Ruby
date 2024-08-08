# EscPosPrinterCommands class in Ruby
# This class holds constants and settings related to ESC/POS printer commands.
# It defines various commands for text formatting, barcode settings, and more.

require_relative 'esc_pos_charset_encoding'
require 'rqrcode'

class EscPosPrinterCommands

  attr_accessor :printer_data, :charset_encoding, :use_esc_asterisk_command

  def initialize(printer_data, charset_encoding = nil, use_esc_asterisk_command = false)
    @printer_data = printer_data
    @charset_encoding = (charset_encoding != nil) ? charset_encoding : EscPosCharsetEncoding.new(charset_name: "windows-1252", esc_pos_charset_id: 6)
    @use_esc_asterisk_command = use_esc_asterisk_command

    @current_text_size = Escpos::TEXT_SIZE_NORMAL
    @current_text_color = Escpos::TEXT_COLOR_BLACK
    @current_text_reverse_color = Escpos::TEXT_COLOR_REVERSE_OFF
    @current_text_bold = Escpos::TEXT_WEIGHT_NORMAL
    @current_text_underline = Escpos::TEXT_UNDERLINE_OFF
    @current_text_double_strike = Escpos::TEXT_DOUBLE_STRIKE_OFF
  end

  def self.init_gsv0_command(bytes_by_line, bitmap_height)
    x_h = bytes_by_line / 256
    x_l = bytes_by_line - (x_h * 256)
    y_h = bitmap_height / 256
    y_l = bitmap_height - (y_h * 256)

    image_bytes = [0x1D, 0x76, 0x30, 0x00, x_l, x_h, y_l, y_h]
    image_bytes.pack('C*') + "\x00" * (8 + bytes_by_line * bitmap_height)
  end

  # Convert Bitmap instance to a byte array compatible with ESC/POS printer
  def self.bitmap_to_bytes(bitmap, gradient)
    bitmap_width = bitmap.width
    bitmap_height = bitmap.height
    bytes_by_line = (bitmap_width / 8.0).ceil

    image_bytes = init_gsv0_command(bytes_by_line, bitmap_height)

    i = 8
    greyscale_coefficient_init = 0
    gradient_step = 6
    color_level_step = 765.0 / (15 * gradient_step + gradient_step - 1)

    bitmap_height.times do |pos_y|
      greyscale_coefficient = greyscale_coefficient_init
      greyscale_line = pos_y % gradient_step
      bitmap_width.step(by: 8, to: bitmap_width - 1) do |j|
        b = 0
        8.times do |k|
          pos_x = j + k
          next if pos_x >= bitmap_width

          color = bitmap.get_pixel(pos_x, pos_y)
          red = (color >> 16) & 255
          green = (color >> 8) & 255
          blue = color & 255

          if gradient
            if (red + green + blue) < ((greyscale_coefficient * gradient_step + greyscale_line) * color_level_step)
              b |= 1 << (7 - k)
            end
          else
            if red < 160 || green < 160 || blue < 160
              b |= 1 << (7 - k)
            end
          end

          greyscale_coefficient += 5
          greyscale_coefficient -= 16 if greyscale_coefficient > 15
        end
        image_bytes[i] = b
        i += 1
      end

      greyscale_coefficient_init += 2
      greyscale_coefficient_init = 0 if greyscale_coefficient_init > 15
    end

    image_bytes
  end

  def self.convert_gsv0_to_esc_asterisk(bytes)
    x_l = bytes[4] & 0xFF
    x_h = bytes[5] & 0xFF
    y_l = bytes[6] & 0xFF
    y_h = bytes[7] & 0xFF
    bytes_by_line = x_h * 256 + x_l
    dots_by_line = bytes_by_line * 8
    n_h = dots_by_line / 256
    n_l = dots_by_line % 256
    image_height = y_h * 256 + y_l
    image_line_height_count = (image_height / 24.0).ceil
    image_bytes_size = 6 + bytes_by_line * 24

    returned_bytes = [Escpos::LINE_SPACING_24]
    image_line_height_count.times do |i|
      px_base_row = i * 24
      image_bytes = [0x1B, 0x2A, 0x21, n_l, n_h].pack('C*') + "\x00" * (image_bytes_size - 6)
      (5...image_bytes_size).each do |j|
        img_byte = j - 5
        byte_row = img_byte % 3
        px_column = img_byte / 3
        bit_column = 1 << (7 - px_column % 8)
        px_row = px_base_row + byte_row * 8
        (0...8).each do |k|
          index_bytes = bytes_by_line * (px_row + k) + px_column / 8 + 8
          break if index_bytes >= bytes.length

          is_black = (bytes[index_bytes] & bit_column) == bit_column
          if is_black
            image_bytes[j] |= (1 << (7 - k))
          end
        end
      end
      image_bytes[-1] = 0x0A.chr
      returned_bytes << image_bytes
    end
    returned_bytes << Escpos::LINE_SPACING_30

    returned_bytes
  end

  def self.qr_code_data_to_bytes(data, size)
    qr = RQRCode::QRCode.new(data, size: size, level: :l)

    byte_matrix = qr.to_s

    width = qr.modules.size
    height = width
    coefficient = (size / width.to_f).round
    image_width = width * coefficient
    image_height = height * coefficient
    bytes_by_line = (image_width / 8.0).ceil
    i = 8

    if coefficient < 1
      return init_gsv0_command(0, 0)
    end

    image_bytes = init_gsv0_command(bytes_by_line, image_height)

    height.times do |y|
      line_bytes = Array.new(bytes_by_line, 0)
      x = -1
      multiple_x = coefficient
      is_black = false
      bytes_by_line.times do |j|
        b = 0
        8.times do |k|
          if multiple_x == coefficient
            is_black = (x += 1) < width && byte_matrix[y * width + x] == '1'
            multiple_x = 0
          end
          if is_black
            b |= (1 << (7 - k))
          end
          multiple_x += 1
        end
        line_bytes[j] = b
      end

      coefficient.times do
        image_bytes[i, line_bytes.length] = line_bytes.pack('C*')
        i += line_bytes.length
      end
    end

    image_bytes
  end

  # Reset printer's parameters.
  def reset
    @printer_data.write(Escpos::RESET_PRINTER)
    self
  end

  # Set text alignment.
  def set_align(align)
    @printer_data.write(align)
    self
  end

  # Print text with optional formatting parameters.
  def print_text(text, text_size = nil, text_color = nil, text_reverse_color = nil, text_bold = nil, text_underline = nil, text_double_strike = nil)
    text_size ||= Escpos::TEXT_SIZE_NORMAL
    text_color ||= Escpos::TEXT_COLOR_BLACK
    text_reverse_color ||= Escpos::TEXT_COLOR_REVERSE_OFF
    text_bold ||= Escpos::TEXT_WEIGHT_NORMAL
    text_underline ||= Escpos::TEXT_UNDERLINE_OFF
    text_double_strike ||= Escpos::TEXT_DOUBLE_STRIKE_OFF

    begin
      text_bytes = text.encode(@charset_encoding.charset_name)

      # Write the charset command.
      @printer_data.write(@charset_encoding.charset_command)

      # Apply text size if different.
      if @current_text_size != text_size
        @printer_data.write(text_size)
        @current_text_size = text_size
      end

      # Apply text double strike if different.
      if @current_text_double_strike != text_double_strike
        @printer_data.write(text_double_strike)
        @current_text_double_strike = text_double_strike
      end

      # Apply text underline if different.
      if @current_text_underline != text_underline
        @printer_data.write(text_underline)
        @current_text_underline = text_underline
      end

      # Apply text bold if different.
      if @current_text_bold != text_bold
        @printer_data.write(text_bold)
        @current_text_bold = text_bold
      end

      # Apply text color if different.
      if @current_text_color != text_color
        @printer_data.write(text_color)
        @current_text_color = text_color
      end

      # Apply text reverse color if different.
      if @current_text_reverse_color != text_reverse_color
        @printer_data.write(text_reverse_color)
        @current_text_reverse_color = text_reverse_color
      end

      # Print the text.
      @printer_data.write(text_bytes)

    rescue Encoding::UndefinedConversionError => e
      puts "Encoding error: #{e.message}"
      raise EscPosEncodingException, e.message
    end

    self
  end

  def use_esc_asterisk_command(enable)
    @use_esc_asterisk_command = enable
    self
  end

  def print_image(image)
    bytes_to_print = @use_esc_asterisk_command ? convert_gsv0_to_esc_asterisk(image) : [image]

    bytes_to_print.each do |bytes|
      @printer_data.write(bytes)
    end

    self
  end

  def print_barcode(barcode)
    code = barcode.code
    barcode_length = barcode.code_length
    barcode_command = [0x1D, 0x6B, barcode.barcode_type, barcode_length].pack('C*') + code.bytes.pack('C*')

    @printer_data.write([0x1D, 0x48, barcode.text_position].pack('C*'))
    @printer_data.write([0x1D, 0x77, barcode.col_width].pack('C*'))
    @printer_data.write([0x1D, 0x68, barcode.height].pack('C*'))
    @printer_data.write(barcode_command)

    self
  end

  def print_qrcode(qr_code_type, text, size)
    size = [[size, 1].max, 16].min

    begin
      text_bytes = text.encode('UTF-8').bytes
      command_length = text_bytes.length + 3
      pL = command_length % 256
      pH = command_length / 256

      @printer_data.write([0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, qr_code_type, 0x00].pack('C*'))
      @printer_data.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size].pack('C*'))
      @printer_data.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30].pack('C*'))

      qr_code_command = [0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30].pack('C*') + text_bytes.pack('C*')
      @printer_data.write(qr_code_command)
      @printer_data.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30].pack('C*'))
    rescue Encoding::UndefinedConversionError => e
      raise EscPosEncodingException, e.message
    end

    self
  end

  def new_line(align = nil)
    @printer_data.write(Escpos::LF)

    @printer_data.write(align) if align
    self
  end

  def feed_paper(dots)
    if dots > 0
      @printer_data.write(Escpos::FEED_PAPER_COMMAND + dots.chr)
    end

    self
  end

  def cut_paper
    @printer_data.write(Escpos::CUT_PAPER)
    @printer_data.save("receipt.dat")
    self
  end

  def open_cash_box
    @printer_data.write(Escpos::OPEN_CASH_BOX)
    self
  end

  def get_charset_encoding
    @charset_encoding
  end
end