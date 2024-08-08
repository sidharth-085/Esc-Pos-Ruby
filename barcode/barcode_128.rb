class Barcode128 < Barcode
  def initialize(printer_size, code, width_mm, height_mm, text_position)
    super(printer_size, Escpos::BARCODE_TYPE_128, code, width_mm, height_mm, text_position)
  end

  def get_code_length
    code.length
  end

  def get_cols_count
    (get_code_length + 5) * 11
  end
end