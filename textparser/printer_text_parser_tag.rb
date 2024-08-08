class PrinterTextParserTag
  attr_reader :tag_name, :attributes, :length

  def initialize(tag)
    tag = tag.strip

    if !tag.start_with?('<') || !tag.end_with?('>')
      return
    end

    @length = tag.length
    open_tag_index = tag.index('<')
    close_tag_index = tag.index('>')
    next_space_index = tag.index(' ')

    if next_space_index && next_space_index < close_tag_index
      @tag_name = tag[(open_tag_index + 1)...next_space_index].downcase

      attributes_string = tag[(next_space_index + 1)...close_tag_index].strip
      @attributes = {}

      while attributes_string.include?("='")
        egal_pos = attributes_string.index("='")
        end_pos = attributes_string.index("'", egal_pos + 2)

        attribute_name = attributes_string[0...egal_pos].strip
        attribute_value = attributes_string[(egal_pos + 2)...end_pos]

        if !attribute_name.empty?
          @attributes[attribute_name] = attribute_value
        end

        attributes_string = attributes_string[(end_pos + 1)..-1].strip
      end
    else
      @tag_name = tag[(open_tag_index + 1)...close_tag_index].downcase
      @attributes = {}
    end

    if @tag_name.start_with?('/')
      @tag_name = @tag_name[1..-1]
      @is_close_tag = true
    else
      @is_close_tag = false
    end
  end

  def get_attribute(key)
    @attributes[key]
  end

  def has_attribute?(key)
    @attributes.key?(key)
  end

  def is_close_tag?
    @is_close_tag
  end
end