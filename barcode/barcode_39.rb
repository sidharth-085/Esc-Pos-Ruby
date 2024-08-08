class Barcode39 < Barcode
  def initialize(printer_size, code, width_mm, height_mm, text_position)
    super(printer_size, Escpos::BARCODE_TYPE_39, code, width_mm, height_mm, text_position)
  end

  def get_code_length
    code.length
  end

  def get_cols_count
    (get_code_length + 4) * 16
  end
end