module ValidatesCreation
  def _validate_create *args
    raise "creation error" if args.any? { |e| e.empty? }
  end
end

module HTMLSanitizer
  def _sanitize_line_breaks message
    message.gsub("\n", "<br />")
  end
end
