class BarcodeUPCA < BarcodeNumber
  def initialize(printer_size, code, width_mm, height_mm, text_position)
    super(printer_size, Escpos::BARCODE_TYPE_UPCA, code, width_mm, height_mm, text_position)
  end

  def get_code_length
    12
  end
end