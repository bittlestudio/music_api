module UploadHelper
  def self.upload_file(path, file)

    unless File.directory?(path)
      system 'mkdir', '-p', path
    end

    File.open(Rails.root.join(path, file.original_filename), 'wb') do |f|
      f.write(file.read)
      f.close
    end
  end

  def self.delete_file(path, filename)
    path_to_file = Rails.root.join(path, filename)
    File.delete(path_to_file) if File.exist?(path_to_file)
  end
end