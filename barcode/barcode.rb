class Barcode
  attr_reader :barcode_type, :code, :height, :text_position, :col_width

  def initialize(printer_size, barcode_type, code, width_mm, height_mm, text_position)
    @barcode_type = barcode_type
    @code = code
    @height = printer_size.mm_to_px(height_mm)
    @text_position = text_position

    width_mm = printer_size.printer_width_mm * 0.7 if width_mm.zero?

    wanted_px_width = width_mm > printer_size.printer_width_mm ? printer_size.printer_width_px : printer_size.mm_to_px(width_mm)
    @col_width = (wanted_px_width.to_f / get_cols_count).round

    if (@col_width * get_cols_count) > printer_size.printer_width_px
      @col_width -= 1
    end

    if @col_width.zero?
      raise EscPosBarcodeException, 'Barcode is too long for the paper size.'
    end
  end

  def get_code_length
    raise NotImplementedError, 'Subclasses must define the get_code_length method.'
  end

  def get_cols_count
    raise NotImplementedError, 'Subclasses must define the get_cols_count method.'
  end
end