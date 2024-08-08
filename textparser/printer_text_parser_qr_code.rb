class PrinterTextParserQRCode < PrinterTextParserImg

  def self.init_constructor(printer_text_parser_column, qr_code_attributes, data)
    printer = printer_text_parser_column.line.text_parser.printer
    data.strip!

    size = printer.mm_to_px(20.0)

    if qr_code_attributes.key?(PrinterTextParser::ATTR_QRCODE_SIZE)
      qr_code_attribute = qr_code_attributes[PrinterTextParser::ATTR_QRCODE_SIZE]
      if qr_code_attribute.nil?
        raise EscPosParserException, "Invalid QR code attribute: #{PrinterTextParser::ATTR_QRCODE_SIZE}"
      end
      begin
        size = printer.mm_to_px(qr_code_attribute.to_f)
      rescue ArgumentError
        raise EscPosParserException, "Invalid QR code #{PrinterTextParser::ATTR_QRCODE_SIZE} value"
      end
    end

    EscPosPrinterCommands.qr_code_data_to_bytes(data, size)
  end

  def initialize(printer_text_parser_column, text_align, qr_code_attributes, data)
    super(
      printer_text_parser_column,
      text_align,
      self.class.init_constructor(printer_text_parser_column, qr_code_attributes, data)
    )
  end
end
