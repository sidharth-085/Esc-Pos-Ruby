class PrinterTextParserString
  attr_reader :printer, :text, :text_size, :text_color, :text_reverse_color, :text_bold, :text_underline, :text_double_strike

  def initialize(printer_text_parser_column, text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    @printer = printer_text_parser_column.line.text_parser.printer
    @text = text
    @text_size = text_size
    @text_color = text_color
    @text_reverse_color = text_reverse_color
    @text_bold = text_bold
    @text_underline = text_underline
    @text_double_strike = text_double_strike
  end

  def length
    charset_encoding = printer.get_encoding
    coef = case text_size
           when Escpos::TEXT_SIZE_DOUBLE_WIDTH, Escpos::TEXT_SIZE_BIG
             2
           when Escpos::TEXT_SIZE_BIG_2
             3
           when Escpos::TEXT_SIZE_BIG_3
             4
           when Escpos::TEXT_SIZE_BIG_4
             5
           when Escpos::TEXT_SIZE_BIG_5
             6
           when Escpos::TEXT_SIZE_BIG_6
             7
           else
             1
           end

    if charset_encoding
      begin
        text.bytesize * coef
      rescue Encoding::ConverterNotFoundError => e
        raise EscPosEncodingException, e.message
      end
    else
      text.length * coef
    end
  end

  def print(printer_socket)
    printer_socket.print_text(text, text_size, text_color, text_reverse_color, text_bold, text_underline, text_double_strike)
    self
  end
end