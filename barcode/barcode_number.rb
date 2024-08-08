class BarcodeNumber < Barcode
  def initialize(printer_size, barcode_type, code, width_mm, height_mm, text_position)
    super(printer_size, barcode_type, code, width_mm, height_mm, text_position)
    check_code
  end

  def get_cols_count
    get_code_length * 7 + 11
  end

  private

  def check_code
    code_length = get_code_length - 1

    if @code.length < code_length
      raise EscPosBarcodeException, "Code is too short for the barcode type."
    end

    begin
      code = @code[0, code_length]
      total_barcode_key = 0
      code_length.times do |i|
        pos = code_length - 1 - i
        int_code = code[pos].to_i
        int_code *= 3 if i.even?
        total_barcode_key += int_code
      end

      barcode_key = (10 - (total_barcode_key % 10)).to_s
      barcode_key = "0" if barcode_key.length == 2
      @code = code + barcode_key

    rescue StandardError => e
      puts e.message
      raise EscPosBarcodeException, "Invalid barcode number"
    end
  end
end