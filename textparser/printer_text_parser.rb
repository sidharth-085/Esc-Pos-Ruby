require_relative 'printer_text_parser_line'

class PrinterTextParser
  
  TAGS_ALIGN_LEFT = "L"
  TAGS_ALIGN_CENTER = "C"
  TAGS_ALIGN_RIGHT = "R"
  TAGS_ALIGN = [TAGS_ALIGN_LEFT, TAGS_ALIGN_CENTER, TAGS_ALIGN_RIGHT]

  TAGS_IMAGE = "img"
  TAGS_BARCODE = "barcode"
  TAGS_QRCODE = "qrcode"

  ATTR_BARCODE_WIDTH = "width"
  ATTR_BARCODE_HEIGHT = "height"
  ATTR_BARCODE_TYPE = "type"
  ATTR_BARCODE_TYPE_EAN8 = "ean8"
  ATTR_BARCODE_TYPE_EAN13 = "ean13"
  ATTR_BARCODE_TYPE_UPCA = "upca"
  ATTR_BARCODE_TYPE_UPCE = "upce"
  ATTR_BARCODE_TYPE_128 = "128"
  ATTR_BARCODE_TYPE_39 = "39"
  ATTR_BARCODE_TEXT_POSITION = "text"
  ATTR_BARCODE_TEXT_POSITION_NONE = "none"
  ATTR_BARCODE_TEXT_POSITION_ABOVE = "above"
  ATTR_BARCODE_TEXT_POSITION_BELOW = "below"

  TAGS_FORMAT_TEXT_FONT = "font"
  TAGS_FORMAT_TEXT_BOLD = "b"
  TAGS_FORMAT_TEXT_UNDERLINE = "u"
  TAGS_FORMAT_TEXT = [TAGS_FORMAT_TEXT_FONT, TAGS_FORMAT_TEXT_BOLD, TAGS_FORMAT_TEXT_UNDERLINE]

  ATTR_FORMAT_TEXT_UNDERLINE_TYPE = "type"
  ATTR_FORMAT_TEXT_UNDERLINE_TYPE_NORMAL = "normal"
  ATTR_FORMAT_TEXT_UNDERLINE_TYPE_DOUBLE = "double"

  ATTR_FORMAT_TEXT_FONT_SIZE = "size"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG = "big"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG_2 = "big-2"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG_3 = "big-3"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG_4 = "big-4"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG_5 = "big-5"
  ATTR_FORMAT_TEXT_FONT_SIZE_BIG_6 = "big-6"
  ATTR_FORMAT_TEXT_FONT_SIZE_TALL = "tall"
  ATTR_FORMAT_TEXT_FONT_SIZE_WIDE = "wide"
  ATTR_FORMAT_TEXT_FONT_SIZE_NORMAL = "normal"

  ATTR_FORMAT_TEXT_FONT_COLOR = "color"
  ATTR_FORMAT_TEXT_FONT_COLOR_BLACK = "black"
  ATTR_FORMAT_TEXT_FONT_COLOR_BG_BLACK = "bg-black"
  ATTR_FORMAT_TEXT_FONT_COLOR_RED = "red"
  ATTR_FORMAT_TEXT_FONT_COLOR_BG_RED = "bg-red"

  ATTR_QRCODE_SIZE = "size"

  def self.get_regex_align_tags
    if @regex_align_tags.nil?
      @regex_align_tags = TAGS_ALIGN.map { |tag| "\\[#{tag}\\]" }.join("|")
    end
    @regex_align_tags
  end

  def self.is_tag_text_format?(tag_name)
    tag_name = tag_name[1..-1] if tag_name.start_with?("/")
    TAGS_FORMAT_TEXT.include?(tag_name)
  end

  def self.array_byte_drop_last(arr)
    return arr if arr.empty?
    arr[0...-1]
  end

  def self.array_byte_push(arr, add)
    arr + [add]
  end

  attr_accessor :printer, :text
  attr_reader :text_size, :text_color, :text_reverse_color, :text_bold, :text_underline, :text_double_strike

  def initialize(printer)
    @printer = printer
    @text = ""
    @text_size = [Escpos::TEXT_SIZE_NORMAL]
    @text_color = [Escpos::TEXT_COLOR_BLACK]
    @text_reverse_color = [Escpos::TEXT_COLOR_REVERSE_OFF]
    @text_bold = [Escpos::TEXT_WEIGHT_NORMAL]
    @text_underline = [Escpos::TEXT_UNDERLINE_OFF]
    @text_double_strike = [Escpos::TEXT_DOUBLE_STRIKE_OFF]
  end

  def set_formatted_text(text)
    @text = text
    self
  end

  def get_last_text_size
    @text_size.last
  end

  def add_text_size(new_text_size)
    @text_size = self.class.array_byte_push(@text_size, new_text_size)
    self
  end

  def drop_last_text_size
    @text_size = self.class.array_byte_drop_last(@text_size) if @text_size.length > 1
    self
  end

  def get_last_text_color
    @text_color.last
  end

  def add_text_color(new_text_color)
    @text_color = self.class.array_byte_push(@text_color, new_text_color)
    self
  end

  def drop_last_text_color
    @text_color = self.class.array_byte_drop_last(@text_color) if @text_color.length > 1
    self
  end

  def get_last_text_reverse_color
    @text_reverse_color.last
  end

  def add_text_reverse_color(new_text_reverse_color)
    @text_reverse_color = self.class.array_byte_push(@text_reverse_color, new_text_reverse_color)
    self
  end

  def drop_last_text_reverse_color
    @text_reverse_color = self.class.array_byte_drop_last(@text_reverse_color) if @text_reverse_color.length > 1
    self
  end

  def get_last_text_bold
    @text_bold.last
  end

  def add_text_bold(new_text_bold)
    @text_bold = self.class.array_byte_push(@text_bold, new_text_bold)
    self
  end

  def drop_text_bold
    @text_bold = self.class.array_byte_drop_last(@text_bold) if @text_bold.length > 1
    self
  end

  def get_last_text_underline
    @text_underline.last
  end

  def add_text_underline(new_text_underline)
    @text_underline = self.class.array_byte_push(@text_underline, new_text_underline)
    self
  end

  def drop_last_text_underline
    @text_underline = self.class.array_byte_drop_last(@text_underline) if @text_underline.length > 1
    self
  end

  def get_last_text_double_strike
    @text_double_strike.last
  end

  def add_text_double_strike(new_text_double_strike)
    @text_double_strike = self.class.array_byte_push(@text_double_strike, new_text_double_strike)
    self
  end

  def drop_last_text_double_strike
    @text_double_strike = self.class.array_byte_drop_last(@text_double_strike) if @text_double_strike.length > 1
    self
  end

  def parse
    string_lines = @text.split(/\n|\r\n/)
    lines = string_lines.map { |line| PrinterTextParserLine.new(self, line) }
    lines
  end
end