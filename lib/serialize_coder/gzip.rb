module SerializeCoder
  class Gzip
    class << self
      def load(compressed)
        if compressed.nil? || compressed.empty?
          compressed
        else
          ActiveSupport::Gzip.decompress(compressed)
        end
      end

      def dump(data)
        if data.is_a?(ActionDispatch::Http::UploadedFile)
          data = data.read
        end

        if data.nil? || data.empty?
          data
        else
          ActiveSupport::Gzip.compress(data)
        end
      end
    end # of class methods
  end
end

