class CreateDerivativesJob < ActiveJob::Base
  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  def perform(file_set, file_id)
    return if file_set.video? && !CurationConcerns.config.enable_ffmpeg
    filename = CurationConcerns::WorkingDirectory.find_or_retrieve(file_id, file_set.id)

    file_set.create_derivatives(filename)

    #This is the last step in the process ( ingest job -> characterization job -> create derivative (last step))
    #So now it's safe to remove the file uploaded file.
    if File.exist?(filename)
      File.delete (filename)
    end

    # Reload from Fedora and reindex for thumbnail and extracted text
    file_set.reload
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end
end
