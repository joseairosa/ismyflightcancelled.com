class FilesRepository
  FILES_LIST = [
    'config/ryanair_september.yml'
  ]

  def initialize
    @files = FILES_LIST.each_with_object({}) do |file_path, res|
      res[File.basename(file_path, ".*")] = YAML.load_file(file_path)['flights']
    end
  end

  def to_h
    @files
  end
end

FILES_REPOSITORY = FilesRepository.new.to_h
