class EmblemToHbs
  def convert
    Dir.glob("**/*.emblem").each do |file|
      convert_file(file)
    end
  end

  def convert_file(file)
    `emblem2hbs #{file}`
    File.delete(file)
  end
end

EmblemToHbs.new.convert