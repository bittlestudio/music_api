module HasFiles

  # +1 shows familiarity with Ruby syntactic sugar (trailing unless clause) - can help code readability
  # -1 a lot of these are procedural methods that could be part of a model layer mixin or concern
  #### I could have definitely implemented these two in the model layer.
  def validate_mime_type(type, validtypes)
    raise "Uploaded file MIME type is not valid. Valid types are #{validtypes.join ", "}" unless validtypes.include? type
  end

  def validate_size(file, maxsizekb)
    raise "Maximum upload size is #{maxsizekb.to_s}KB" unless File.size(file[:tempfile])<= maxsizekb*1024
  end

  def upload_file(path, file)
    uploadedfile = ActionDispatch::Http::UploadedFile.new(file)
    UploadHelper::upload_file("#{path}", uploadedfile)
    uploadedfile
  end

  def delete_file(path, name)
    if name
      UploadHelper::delete_file(path, name)
    end
  end

end