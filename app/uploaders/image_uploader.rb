# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  storage :fog

  def filename
    name = original_filename.present? ? without_extension(original_filename) : "image"
    "#{name}-#{unique_id}.#{file.extension}"
  end
  
  def store_dir
    "#{model.class.to_s.downcase.pluralize}/#{mounted_as.to_s.downcase.pluralize}"
  end
  
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  private

  def without_extension(filename)
    extension_white_list.each do |extension|
      if filename.ends_with? "." + extension
        return filename[0...-extension.length - 1]
      end
    end
  end

  def unique_id
    loop do
      uuid = SecureRandom.uuid
      break model.image_id = uuid unless model.class.unscoped.where("#{mounted_as.to_s}_id = ?", uuid).first
    end
    
    model.image_id
  end
end
