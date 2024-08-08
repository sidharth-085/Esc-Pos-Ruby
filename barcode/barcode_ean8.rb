class BarcodeEAN8 < BarcodeNumber
  def initialize(printer_size, code, width_mm, height_mm, text_position)
    super(printer_size, Escpos::BARCODE_TYPE_EAN8, code, width_mm, height_mm, text_position)
  end

  def get_code_length
    8
  end
end