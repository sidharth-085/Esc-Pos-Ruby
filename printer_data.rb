require 'base64'
require_relative 'escpos'

module Escpos 
  class PrinterData
    attr_reader :dataBytes
  
    # Data is initialized with empty bytes
    def initialize
      @dataBytes = "".force_encoding("ASCII-8BIT")
      @dataBytes += Escpos::RESET_PRINTER
    end
  
    # Writing the data with bytes
    def write(bytes)
      @dataBytes += bytes
    end
  
    alias :<< :write
  
    def save(path)
      File.open(path, "wb") do |file|
        file.print to_escpos
      end
    end
  
    def to_escpos
      @dataBytes
    end
  
    def to_base64
      Base64.strict_encode64 @dataBytes
    end
  end
end