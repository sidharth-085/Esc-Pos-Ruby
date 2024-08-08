module IPrinterTextParserElement
  def length
    raise NotImplementedError, "Subclasses must implement the length method"
  end

  def print(printer_socket)
    raise NotImplementedError, "Subclasses must implement the print method"
  end
end