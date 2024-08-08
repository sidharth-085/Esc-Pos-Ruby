require_relative 'printer_data'
require_relative 'esc_pos_printer'
require_relative 'exceptions/esc_pos_barcode_exception'
require_relative 'exceptions/esc_pos_encoding_exception'
require_relative 'exceptions/esc_pos_parser_exception'
require_relative 'escpos'

begin
  # Assuming you have a method to get the selected device
  printer_data = Escpos::PrinterData.new
  printer = EscPosPrinter.new(printer_data, 203, 72.0, 47)

  receipt_data = 
    "[C]\n" +
    "[C]<font size='big'>BLUESAPLING</font>\n" +
    "[C]1st Floor, 835, 1st Main Road\n" +
    "[C]A-Block Sahakar Nagar, Bengaluru\n" +
    "[L]\n" +
    "[C]<b>Retail Invoice</b>\n" +
    "[L]\n" +

    "[L]Invoice No:[R]IVC/20-21/10003\n" +
    "[L]Date:[R]23/03/2024\n" +
    "[L]Branch:[R]MAIN BRANCH\n" +
    "[L]Warehouse:[R]MAIN WAREHOUSE\n" +
    "[L]Due Date:[R] 15/03/2024\n" +
    "[L]STATUS:[R]CLOSED\n" +
    "[L]User:[R]Rajesh\n" +

    "[L]Customer:[R]Taya LLC\n" +
    "[L]GSTIN:[R]33AAAGP0685F1ZH\n" +
    "[L]\n" +
    "[L]Billing Address: Sector-18, near Royal Gardens, Bangalore - 560102, Karnataka, Mob. 9899099099\n" +
    "[L]\n" +
    "[L]Shipping Address: Sector-18, near Royal Gardens, Bangalore - 560102, Karnataka, Mob. 9899099099\n" +
    "[L]\n" +

    "[C]-----------------------------------------------\n" +
    "[L]<b>Product</b>[R]<b>Quantity</b>[R]<b>Total</b>\n" +
    "[C]-----------------------------------------------\n" +
    "[L]Aloo Bhujiya[R]1[R]Rs 200.00\n" +
    "[L]Crax[R]1[R]Rs 560.00\n" +
    "[C]-----------------------------------------------\n" +

    "[L]Sub Total[R]Rs 1,000.00\n" +
    "[L]Discount Amt[R]Rs 0.00\n" +
    "[L]Item Discount Amt[R]Rs 0.00\n" +
    "[L]Net Amt[R]Rs 1000.00\n" +
    "[L]Tax Amt[R]Rs 120.00\n" +
    "[L]Round Total[R]Rs 1,121.00\n" +
    "[L]Paid[R]Rs 1,121.00\n" +
    "[L]Due[R]Rs 0.00\n" +
    "[C]-----------------------------------------------\n" +
    "[L]\n"

  printer.print_formatted_text_and_cut(receipt_data)

rescue EscPosParserException, EscPosEncodingException, EscPosBarcodeException => e
  # Handle exceptions or re-raise them
  puts "An error occurred: #{e.message}"
  raise e
end