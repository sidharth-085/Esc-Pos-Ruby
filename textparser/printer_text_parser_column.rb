require_relative 'printer_text_parser'
require_relative 'printer_text_parser_line'
require_relative 'printer_text_parser_tag'
require_relative 'printer_text_parser_string'

class PrinterTextParserColumn 
  def self.generate_space(nbr_space)
    " " * nbr_space
  end

  attr_accessor :text_parser_line, :elements

  def initialize(text_parser_line, text_column)
    @text_parser_line = text_parser_line
    @elements = []

    text_parser = @text_parser_line.text_parser
    text_align = PrinterTextParser::TAGS_ALIGN_LEFT
    text_underline_start_column = text_parser.get_last_text_underline
    text_double_strike_start_column = text_parser.get_last_text_double_strike
    text_color_start_column = text_parser.get_last_text_color
    text_reverse_color_start_column = text_parser.get_last_text_reverse_color

    # =================================================================
    # Check the column alignment
    if text_column.length > 2
      case text_column[0, 3].upcase
      when "[#{PrinterTextParser::TAGS_ALIGN_LEFT}]",
           "[#{PrinterTextParser::TAGS_ALIGN_CENTER}]",
           "[#{PrinterTextParser::TAGS_ALIGN_RIGHT}]"
        text_align = text_column[1].upcase
        text_column = text_column[3..]
      end
    end

    trimmed_text_column = text_column.strip
    is_img_or_barcode_line = false

    if @text_parser_line.nbr_columns == 1 && trimmed_text_column.start_with?("<")
      # =================================================================
      # Image or Barcode Lines
      open_tag_index = trimmed_text_column.index("<")
      open_tag_end_index = trimmed_text_column.index(">", open_tag_index + 1) + 1

      if open_tag_index < open_tag_end_index
        text_parser_tag = PrinterTextParserTag.new(trimmed_text_column[open_tag_index...open_tag_end_index])

        case text_parser_tag.tag_name
        when PrinterTextParser::TAGS_IMAGE, PrinterTextParser::TAGS_BARCODE, PrinterTextParser::TAGS_QRCODE
          close_tag = "</#{text_parser_tag.tag_name}>"
          close_tag_position = trimmed_text_column.length - close_tag.length

          if trimmed_text_column[close_tag_position..] == close_tag
            case text_parser_tag.tag_name
            when PrinterTextParser::TAGS_IMAGE
              append_image(text_align, trimmed_text_column[open_tag_end_index...close_tag_position])
            when PrinterTextParser::TAGS_BARCODE
              append_barcode(text_align, text_parser_tag.get_attributes, trimmed_text_column[open_tag_end_index...close_tag_position])
            when PrinterTextParser::TAGS_QRCODE
              append_qrcode(text_align, text_parser_tag.get_attributes, trimmed_text_column[open_tag_end_index...close_tag_position])
            end
            is_img_or_barcode_line = true
          end
        end
      end
    end

    unless is_img_or_barcode_line
      # =================================================================
      # If the tag is for format text

      offset = 0
      loop do
        open_tag_index = text_column.index("<", offset) || text_column.length
        close_tag_index = text_column.index(">", open_tag_index) if open_tag_index != -1

        append_string(text_column[offset...open_tag_index])

        break if close_tag_index.nil?

        close_tag_index += 1
        text_parser_tag = PrinterTextParserTag.new(text_column[open_tag_index...close_tag_index])

        if PrinterTextParser.is_tag_text_format?(text_parser_tag.tag_name)
          if text_parser_tag.is_close_tag?
            case text_parser_tag.tag_name
            when PrinterTextParser::TAGS_FORMAT_TEXT_BOLD
              text_parser.drop_text_bold
            when PrinterTextParser::TAGS_FORMAT_TEXT_UNDERLINE
              text_parser.drop_last_text_underline
              text_parser.drop_last_text_double_strike
            when PrinterTextParser::TAGS_FORMAT_TEXT_FONT
              text_parser.drop_last_text_size
              text_parser.drop_last_text_color
              text_parser.drop_last_text_reverse_color
            end
          else
            case text_parser_tag.tag_name
            when PrinterTextParser::TAGS_FORMAT_TEXT_BOLD
              text_parser.add_text_bold(Escpos::TEXT_WEIGHT_BOLD)
            when PrinterTextParser::TAGS_FORMAT_TEXT_UNDERLINE
              if text_parser_tag.has_attribute?(PrinterTextParser::ATTR_FORMAT_TEXT_UNDERLINE_TYPE)
                case text_parser_tag.get_attribute(PrinterTextParser::ATTR_FORMAT_TEXT_UNDERLINE_TYPE)
                when PrinterTextParser::ATTR_FORMAT_TEXT_UNDERLINE_TYPE_NORMAL
                  text_parser.add_text_underline(Escpos::TEXT_UNDERLINE_LARGE)
                  text_parser.add_text_double_strike(text_parser.get_last_text_double_strike)
                when PrinterTextParser::ATTR_FORMAT_TEXT_UNDERLINE_TYPE_DOUBLE
                  text_parser.add_text_underline(text_parser.get_last_text_underline)
                  text_parser.add_text_double_strike(Escpos::TEXT_DOUBLE_STRIKE_ON)
                end
              else
                text_parser.add_text_underline(Escpos::TEXT_UNDERLINE_LARGE)
                text_parser.add_text_double_strike(text_parser.get_last_text_double_strike)
              end
            when PrinterTextParser::TAGS_FORMAT_TEXT_FONT
              if text_parser_tag.has_attribute?(PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE)
                case text_parser_tag.get_attribute(PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_NORMAL
                  text_parser.add_text_size(Escpos::TEXT_SIZE_NORMAL)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_TALL
                  text_parser.add_text_size(Escpos::TEXT_SIZE_DOUBLE_HEIGHT)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_WIDE
                  text_parser.add_text_size(Escpos::TEXT_SIZE_DOUBLE_WIDTH)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG_2
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG_2)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG_3
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG_3)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG_4
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG_4)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG_5
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG_5)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_SIZE_BIG_6
                  text_parser.add_text_size(Escpos::TEXT_SIZE_BIG_6)
                else
                  text_parser.add_text_size(text_parser.get_last_text_size)
                end
              end

              if text_parser_tag.has_attribute?(PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR)
                case text_parser_tag.get_attribute(PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR_BLACK
                  text_parser.add_text_color(Escpos::TEXT_COLOR_BLACK)
                  text_parser.add_text_reverse_color(Escpos::TEXT_COLOR_REVERSE_OFF)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR_BG_BLACK
                  text_parser.add_text_color(Escpos::TEXT_COLOR_BLACK)
                  text_parser.add_text_reverse_color(Escpos::TEXT_COLOR_REVERSE_ON)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR_RED
                  text_parser.add_text_color(Escpos::TEXT_COLOR_RED)
                  text_parser.add_text_reverse_color(Escpos::TEXT_COLOR_REVERSE_OFF)
                when PrinterTextParser::ATTR_FORMAT_TEXT_FONT_COLOR_BG_RED
                  text_parser.add_text_color(Escpos::TEXT_COLOR_RED)
                  text_parser.add_text_reverse_color(Escpos::TEXT_COLOR_REVERSE_ON)
                else
                  text_parser.add_text_color(text_parser.get_last_text_color)
                  text_parser.add_text_reverse_color(text_parser.get_last_text_reverse_color)
                end
              end
            end
          end
          offset = close_tag_index
        else
          append_string("<")
          offset = open_tag_index + 1
        end
      end

      # =================================================================
      # Define the number of spaces required for the different alignments

      nbr_char_column = @text_parser_line.nbr_char_column
      nbr_char_forgetted = @text_parser_line.nbr_char_forgetted
      nbr_char_column_exceeded = @text_parser_line.nbr_char_column_exceeded
      nbr_char_text_without_tag = 0
      left_space = 0
      right_space = 0

      @elements.each do |text_parser_element|
        nbr_char_text_without_tag += text_parser_element.length
      end

      case text_align
      when PrinterTextParser::TAGS_ALIGN_LEFT
        right_space = nbr_char_column - nbr_char_text_without_tag
      when PrinterTextParser::TAGS_ALIGN_CENTER
        left_space = ((nbr_char_column - nbr_char_text_without_tag) / 2.0).floor
        right_space = nbr_char_column - nbr_char_text_without_tag - left_space
      when PrinterTextParser::TAGS_ALIGN_RIGHT
        left_space = nbr_char_column - nbr_char_text_without_tag
      end

      if nbr_char_forgetted.positive?
        nbr_char_forgetted -= 1
        right_space += 1
      end

      if nbr_char_column_exceeded.negative?
        left_space += nbr_char_column_exceeded
        nbr_char_column_exceeded = 0
        if left_space < 1
          right_space += left_space - 1
          left_space = 1
        end
      end

      if left_space.negative?
        nbr_char_column_exceeded += left_space
        left_space = 0
      end
      if right_space.negative?
        nbr_char_column_exceeded += right_space
        right_space = 0
      end

      if left_space.positive?
        prepend_string_with_params(
          PrinterTextParserColumn.generate_space(left_space),
          Escpos::TEXT_SIZE_NORMAL,
          text_color_start_column,
          text_reverse_color_start_column,
          Escpos::TEXT_WEIGHT_NORMAL,
          text_underline_start_column,
          text_double_strike_start_column
        )
      end
      if right_space.positive?
        append_string_with_params(
          PrinterTextParserColumn.generate_space(right_space),
          Escpos::TEXT_SIZE_NORMAL,
          text_parser.get_last_text_color,
          text_parser.get_last_text_reverse_color,
          Escpos::TEXT_WEIGHT_NORMAL,
          text_parser.get_last_text_underline,
          text_parser.get_last_text_double_strike
        )
      end

      # =================================================================================================
      # nbr_char_forgetted and nbr_char_column_exceeded is use to define number of spaces for the next columns

      @text_parser_line.nbr_char_forgetted = nbr_char_forgetted
      @text_parser_line.nbr_char_column_exceeded = nbr_char_column_exceeded
    end
  end

  def prepend_string(text)
    text_parser = @text_parser_line.text_parser
    prepend_string_with_params(
      text,
      text_parser.get_last_text_size,
      text_parser.get_last_text_color,
      text_parser.get_last_text_reverse_color,
      text_parser.get_last_text_bold,
      text_parser.get_last_text_underline,
      text_parser.get_last_text_double_strike
    )
  end

  def prepend_string_with_params(text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    prepend_element(
      PrinterTextParserString.new(self, text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    )
  end

  def append_string(text)
    text_parser = @text_parser_line.text_parser
    append_string_with_params(
      text,
      text_parser.get_last_text_size,
      text_parser.get_last_text_color,
      text_parser.get_last_text_reverse_color,
      text_parser.get_last_text_bold,
      text_parser.get_last_text_underline,
      text_parser.get_last_text_double_strike
    )
  end

  def append_string_with_params(text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    append_element(
      PrinterTextParserString.new(self, text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    )
  end

  def prepend_image(text_align, hex_string)
    prepend_element(PrinterTextParserImg.new(self, text_align, hex_string))
  end

  def append_image(text_align, hex_string)
    append_element(PrinterTextParserImg.new(self, text_align, hex_string))
  end

  def prepend_barcode(text_align, barcode_attributes, code)
    prepend_element(PrinterTextParserBarcode.new(self, text_align, barcode_attributes, code))
  end

  def append_barcode(text_align, barcode_attributes, code)
    append_element(PrinterTextParserBarcode.new(self, text_align, barcode_attributes, code))
  end

  def prepend_qrcode(text_align, qr_code_attributes, data)
    prepend_element(PrinterTextParserQRCode.new(self, text_align, qr_code_attributes, data))
  end

  def append_qrcode(text_align, qr_code_attributes, data)
    append_element(PrinterTextParserQRCode.new(self, text_align, qr_code_attributes, data))
  end

  def prepend_element(element)
    @elements = [element] + @elements
    self
  end

  def append_element(element)
    @elements += [element]
    self
  end

  def line
    @text_parser_line
  end

  def elements
    @elements
  end
  
end