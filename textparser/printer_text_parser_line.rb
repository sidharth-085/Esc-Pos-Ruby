require_relative 'printer_text_parser_column'
require_relative 'printer_text_parser'

class PrinterTextParserLine
  attr_reader :text_parser, :columns
  attr_accessor :nbr_columns, :nbr_char_column, :nbr_char_forgetted, :nbr_char_column_exceeded

  def initialize(text_parser, text_line)
    @text_parser = text_parser
    nbr_characters_per_line = text_parser.printer.printer_nbr_characters_per_line

    # Create a Regexp object using the pattern from `get_regex_align_tags`
    pattern = Regexp.new(PrinterTextParser.get_regex_align_tags)
    matches = text_line.enum_for(:scan, pattern).map { Regexp.last_match.begin(0) }

    # Process matches and create columns
    columns_list = []
    last_position = 0

    matches.each do |start_position|
      columns_list << text_line[last_position...start_position] if start_position > 0
      last_position = start_position
    end
    columns_list << text_line[last_position..-1]

    @nbr_columns = columns_list.size
    @nbr_char_column = (nbr_characters_per_line.to_f / @nbr_columns).floor
    @nbr_char_forgetted = nbr_characters_per_line - (@nbr_char_column * @nbr_columns)
    @nbr_char_column_exceeded = 0
    @columns = Array.new(@nbr_columns)

    columns_list.each_with_index do |column, i|
      @columns[i] = PrinterTextParserColumn.new(self, column)
    end
  end
end