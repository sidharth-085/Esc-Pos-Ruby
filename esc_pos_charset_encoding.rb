class EscPosCharsetEncoding
  attr_reader :charset_name, :charset_command

  # Create a new instance of EscPosCharsetEncoding
  #
  # @param charset_name [String] Name of charset encoding (e.g., 'windows-1252')
  # @param esc_pos_charset_id [Integer] Id of charset encoding for your printer (e.g., 16)
  def initialize(charset_name:, esc_pos_charset_id:)
    @charset_name = charset_name
    @charset_command = [0x1B, 0x74, esc_pos_charset_id].pack('C*')
  end
  
end