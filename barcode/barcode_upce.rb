class BarcodeUPCE < Barcode
  def initialize(printer_size, code, width_mm, height_mm, text_position)
    super(printer_size, Escpos::BARCODE_TYPE_UPCE, code, width_mm, height_mm, text_position)
    check_code
  end

  def get_code_length
    6
  end

  def get_cols_count
    get_code_length * 7 + 16
  end

  private

  def check_code
    code_length = get_code_length

    if @code.length < code_length
      raise EscPosBarcodeException, "Code is too short for the barcode type."
    end

    begin
      @code = @code[0, code_length]
      @code.each_char do |char|
        Integer(char) # Will raise an exception if char is not a number
      end
    rescue ArgumentError
      raise EscPosBarcodeException, "Invalid barcode number"
    end
  end
end