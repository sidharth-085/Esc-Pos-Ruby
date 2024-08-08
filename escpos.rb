module Escpos 
  
  LF = 0x0A.chr

  RESET_PRINTER = [0x1B, 0x40].pack('C*')

  TEXT_ALIGN_LEFT = [0x1B, 0x61, 0x00].pack('C*')
  TEXT_ALIGN_CENTER = [0x1B, 0x61, 0x01].pack('C*')
  TEXT_ALIGN_RIGHT = [0x1B, 0x61, 0x02].pack('C*')

  TEXT_WEIGHT_NORMAL = [0x1B, 0x45, 0x00].pack('C*')
  TEXT_WEIGHT_BOLD = [0x1B, 0x45, 0x01].pack('C*')

  LINE_SPACING_24 = [0x1b, 0x33, 0x18].pack('C*')
  LINE_SPACING_30 = [0x1b, 0x33, 0x1e].pack('C*')

  TEXT_FONT_A = [0x1B, 0x4D, 0x00].pack('C*')
  TEXT_FONT_B = [0x1B, 0x4D, 0x01].pack('C*')
  TEXT_FONT_C = [0x1B, 0x4D, 0x02].pack('C*')
  TEXT_FONT_D = [0x1B, 0x4D, 0x03].pack('C*')
  TEXT_FONT_E = [0x1B, 0x4D, 0x04].pack('C*')

  TEXT_SIZE_NORMAL = [0x1D, 0x21, 0x00].pack('C*')
  TEXT_SIZE_DOUBLE_HEIGHT = [0x1D, 0x21, 0x01].pack('C*')
  TEXT_SIZE_DOUBLE_WIDTH = [0x1D, 0x21, 0x10].pack('C*')
  TEXT_SIZE_BIG = [0x1D, 0x21, 0x11].pack('C*')
  TEXT_SIZE_BIG_2 = [0x1D, 0x21, 0x22].pack('C*')
  TEXT_SIZE_BIG_3 = [0x1D, 0x21, 0x33].pack('C*')
  TEXT_SIZE_BIG_4 = [0x1D, 0x21, 0x44].pack('C*')
  TEXT_SIZE_BIG_5 = [0x1D, 0x21, 0x55].pack('C*')
  TEXT_SIZE_BIG_6 = [0x1D, 0x21, 0x66].pack('C*')

  TEXT_UNDERLINE_OFF = [0x1B, 0x2D, 0x00].pack('C*')
  TEXT_UNDERLINE_ON = [0x1B, 0x2D, 0x01].pack('C*')
  TEXT_UNDERLINE_LARGE = [0x1B, 0x2D, 0x02].pack('C*')

  TEXT_DOUBLE_STRIKE_OFF = [0x1B, 0x47, 0x00].pack('C*')
  TEXT_DOUBLE_STRIKE_ON = [0x1B, 0x47, 0x01].pack('C*')

  TEXT_COLOR_BLACK = [0x1B, 0x72, 0x00].pack('C*')
  TEXT_COLOR_RED = [0x1B, 0x72, 0x01].pack('C*')

  TEXT_COLOR_REVERSE_OFF = [0x1D, 0x42, 0x00].pack('C*')
  TEXT_COLOR_REVERSE_ON = [0x1D, 0x42, 0x01].pack('C*')

  BARCODE_TYPE_UPCA = 65
  BARCODE_TYPE_UPCE = 66
  BARCODE_TYPE_EAN13 = 67
  BARCODE_TYPE_EAN8 = 68
  BARCODE_TYPE_39 = 69
  BARCODE_TYPE_ITF = 70
  BARCODE_TYPE_128 = 73

  BARCODE_TEXT_POSITION_NONE = 0
  BARCODE_TEXT_POSITION_ABOVE = 1
  BARCODE_TEXT_POSITION_BELOW = 2

  QRCODE_1 = 49
  QRCODE_2 = 50

  OPEN_CASH_BOX = [0x1B, 0x70, 0x00, 0x3C, 0xFF].pack('C*')
  FEED_PAPER_COMMAND = [0x1B, 0x4A].pack('C*')
  CUT_PAPER = [0x1D, 0x56, 0x01].pack('C*')
end