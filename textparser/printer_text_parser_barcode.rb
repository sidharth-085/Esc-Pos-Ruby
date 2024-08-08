class PrinterTextParserBarcode
  include IPrinterTextParserElement

  def initialize(printer_text_parser_column, text_align, barcode_attributes, code)
    printer = printer_text_parser_column.line.text_parser.printer
    code.strip!

    @align = case text_align
             when PrinterTextParser::TAGS_ALIGN_CENTER
               Escpos::TEXT_ALIGN_CENTER
             when PrinterTextParser::TAGS_ALIGN_RIGHT
               Escpos::TEXT_ALIGN_RIGHT
             else
               Escpos::TEXT_ALIGN_LEFT
             end

    @length = printer.printer_nbr_characters_per_line
    height = 10.0

    if barcode_attributes.key?(PrinterTextParser::ATTR_BARCODE_HEIGHT)
      bar_code_attribute = barcode_attributes[PrinterTextParser::ATTR_BARCODE_HEIGHT]

      raise EscPosParserException, "Invalid barcode attribute: #{PrinterTextParser::ATTR_BARCODE_HEIGHT}" if bar_code_attribute.nil?

      height = bar_code_attribute.to_f
    end

    width = 0.0
    if barcode_attributes.key?(PrinterTextParser::ATTR_BARCODE_WIDTH)
      bar_code_attribute = barcode_attributes[PrinterTextParser::ATTR_BARCODE_WIDTH]

      raise EscPosParserException, "Invalid barcode attribute: #{PrinterTextParser::ATTR_BARCODE_WIDTH}" if bar_code_attribute.nil?

      width = bar_code_attribute.to_f
    end

    text_position = Escpos::BARCODE_TEXT_POSITION_BELOW
    if barcode_attributes.key?(PrinterTextParser::ATTR_BARCODE_TEXT_POSITION)
      bar_code_attribute = barcode_attributes[PrinterTextParser::ATTR_BARCODE_TEXT_POSITION]

      raise EscPosParserException, "Invalid barcode attribute: #{PrinterTextParser::ATTR_BARCODE_TEXT_POSITION}" if bar_code_attribute.nil?

      text_position = case bar_code_attribute
                      when PrinterTextParser::ATTR_BARCODE_TEXT_POSITION_NONE
                        Escpos::BARCODE_TEXT_POSITION_NONE
                      when PrinterTextParser::ATTR_BARCODE_TEXT_POSITION_ABOVE
                        Escpos::BARCODE_TEXT_POSITION_ABOVE
                      else
                        Escpos::BARCODE_TEXT_POSITION_BELOW
                      end
    end

    barcode_type = PrinterTextParser::ATTR_BARCODE_TYPE_EAN13
    if barcode_attributes.key?(PrinterTextParser::ATTR_BARCODE_TYPE)
      barcode_type = barcode_attributes[PrinterTextParser::ATTR_BARCODE_TYPE]
      raise EscPosParserException, "Invalid barcode attribute: #{PrinterTextParser::ATTR_BARCODE_TYPE}" if barcode_type.nil?
    end

    case barcode_type
    when PrinterTextParser::ATTR_BARCODE_TYPE_EAN8
      @barcode = BarcodeEAN8.new(printer, code, width, height, text_position)
    when PrinterTextParser::ATTR_BARCODE_TYPE_EAN13
      @barcode = BarcodeEAN13.new(printer, code, width, height, text_position)
    when PrinterTextParser::ATTR_BARCODE_TYPE_UPCA
      @barcode = BarcodeUPCA.new(printer, code, width, height, text_position)
    when PrinterTextParser::ATTR_BARCODE_TYPE_UPCE
      @barcode = BarcodeUPCE.new(printer, code, width, height, text_position)
    when PrinterTextParser::ATTR_BARCODE_TYPE_128
      @barcode = Barcode128.new(printer, code, width, height, text_position)
    when PrinterTextParser::ATTR_BARCODE_TYPE_39
      @barcode = Barcode39.new(printer, code, width, height, text_position)
    else
      raise EscPosParserException, "Invalid barcode attribute: #{PrinterTextParser::ATTR_BARCODE_TYPE}"
    end
  end

  # Get the barcode width in char length.
  def length
    @length
  end

  # Print barcode
  def print(printer_socket)
    printer_socket
      .set_align(@align)
      .print_barcode(@barcode)
    self
  end
end