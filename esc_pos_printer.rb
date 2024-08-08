require_relative 'esc_pos_printer_size'
require_relative 'esc_pos_printer_commands'
require_relative 'exceptions/esc_pos_barcode_exception'
require_relative 'exceptions/esc_pos_encoding_exception'
require_relative 'exceptions/esc_pos_parser_exception'
require_relative 'textparser/printer_text_parser'
require_relative 'textparser/printer_text_parser_string'

class EscPosPrinter < EscPosPrinterSize

  def initialize(printer_data, printer_dpi, printer_width_mm, printer_nbr_characters_per_line, charset_encoding = nil)
    super(printer_dpi: printer_dpi, printer_width_mm: printer_width_mm, printer_nbr_characters_per_line: printer_nbr_characters_per_line)
    @printer = printer_data ? EscPosPrinterCommands.new(printer_data, charset_encoding) : nil
  end

  def use_esc_asterisk_command(enable)
    @printer.use_esc_asterisk_command(enable)
    self
  end

  def print_formatted_text(text)
    print_formatted_text_with_feed(text, 20.0)
  rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
    # Handle exceptions or re-raise them
    raise e
  end

  def print_formatted_text_with_feed(text, mm_feed_paper)
    print_formatted_text_with_dots(text, mm_to_px(mm_feed_paper))
  rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
    # Handle exceptions or re-raise them
    raise e
  end

  def print_formatted_text_with_dots(text, dots_feed_paper)
    return self unless @printer && @printer_nbr_characters_per_line > 0

    begin
      text_parser = PrinterTextParser.new(self)
      lines_parsed = text_parser.set_formatted_text(text).parse

      @printer.reset

      lines_parsed.each do |line|
        columns = line.columns
        last_element = nil

        columns.each do |column|
          elements = column.elements
          elements.each do |element|
            element.print(@printer)
            last_element = element
          end
        end

        @printer.new_line if last_element.is_a?(PrinterTextParserString)
      end

      @printer.feed_paper(dots_feed_paper)
    rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
      # Handle exceptions or re-raise them
      raise e
    end
    self
  end

  def print_formatted_text_and_cut(text)
    print_formatted_text_and_cut_with_feed(text, 20.0)
  rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
    # Handle exceptions or re-raise them
    raise e
  end

  def print_formatted_text_and_cut_with_feed(text, mm_feed_paper)
    print_formatted_text_and_cut_with_dots(text, mm_to_px(mm_feed_paper))
  rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
    # Handle exceptions or re-raise them
    raise e
  end

  def   print_formatted_text_and_cut_with_dots(text, dots_feed_paper)
    return self unless @printer && @printer_nbr_characters_per_line > 0

    begin
      print_formatted_text_with_dots(text, dots_feed_paper)
      @printer.cut_paper
    rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
      # Handle exceptions or re-raise them
      raise e
    end
    self
  end

  def print_formatted_text_and_open_cash_box(text, mm_feed_paper)
    print_formatted_text_and_open_cash_box_with_dots(text, mm_to_px(mm_feed_paper))
  rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
    # Handle exceptions or re-raise them
    raise e
  end

  def print_formatted_text_and_open_cash_box_with_dots(text, dots_feed_paper)
    return self unless @printer && @printer_nbr_characters_per_line > 0

    begin
      print_formatted_text_and_cut_with_dots(text, dots_feed_paper)
      @printer.open_cash_box
    rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
      # Handle exceptions or re-raise them
      raise e
    end
    self
  end

  def get_encoding
    @printer.get_charset_encoding
  end
  
end