# frozen_string_literal: true

require 'set'
require 'fileutils'

class SiteDiff
  # SiteDiff Cache Handler.
  class Cache
    TIMESTAMP_FILE = 'timestamp'

    attr_accessor :read_tags, :write_tags

    ##
    # Creates a Cache object.
    def initialize(opts = {})
      @create = opts[:create]

      # Read and Write tags are sets that can contain :before and :after.
      # They indicate whether we should use the cache for reading or writing.
      @read_tags = Set.new
      @write_tags = Set.new
      @timestamp_flag = { before: false, after: false }

      # The directory used by the cache for storage.
      @dir = opts[:directory] || '.'
    end

    ##
    # Is a tag cached?
    # TODO: Rename it to is_cached? as it makes more sense.
    def tag?(tag)
      File.directory?(File.join(@dir, 'snapshot', tag.to_s))
    end

    ##
    # Get data from cache.
    def get(tag, path)
      return nil unless @read_tags.include? tag

      filename = File.join(
        @dir,
        'snapshot',
        tag.to_s,
        *path.split(File::SEPARATOR)
      )

      filename = File.join(filename, 'index.html') if File.directory?(filename)
      return nil unless File.file? filename

      Marshal.load(File.read(filename))
    end

    ##
    # Set data to cache.
    def set(tag, path, result)
      return unless @write_tags.include? tag

      save_timestamp(tag)
      filename = File.join(
        @dir,
        'snapshot',
        tag.to_s,
        *path.split(File::SEPARATOR)
      )

      filename = File.join(filename, 'index.html') if File.directory?(filename)
      filepath = Pathname.new(filename)
      unless filepath.dirname.directory?
        begin
          filepath.dirname.mkpath
        rescue Errno::EEXIST
          curdir = filepath
          curdir = curdir.parent until curdir.exist?
          tempname = "#{curdir.dirname}/#{curdir.basename}.temporary"
          # tempname = curdir.dirname + (curdir.basename.to_s + '.temporary')
          # May cause problems if action is not atomic!
          # Move existing file to dir/index.html first
          # Not robust! Should generate an UUID or something.
          if File.exist?(tempname)
            SiteDiff.log "Overwriting file #{tempname}", :warning
          end
          curdir.rename(tempname)
          filepath.dirname.mkpath
          # Should only happen in strange situations such as when the path
          # is foo/index.html/bar (i.e., index.html is a directory)
          if File.exist?("#{curdir}/index.html")
            SiteDiff.log "Overwriting file #{tempname}", :warning
          end
          File.rename(tempname, "#{curdir}/index.html")
          # tempname.rename(curdir + 'index.html')
        end
      end
      File.open(filename, 'w') { |file| file.write(Marshal.dump(result)) }
    end

    ##
    # TODO: Document this or remove it if unused.
    def key(tag, path)
      # Ensure encoding stays the same!
      Marshal.dump([tag, path.encode('UTF-8')])
    end

    ##
    # Ensures that a directory exists.
    def get_dir(directory)
      # Create the dir. Must go before cache initialization!
      @dir = Pathname.new(directory || '.')
      @dir.mkpath unless @dir.directory?
      @dir.to_s
    end

    private

    def save_timestamp(tag)
      # run once
      return if @timestamp_flag[tag]

      @timestamp_flag[tag] = true
      cache_dir = File.join(@dir, 'snapshot', tag.to_s)
      if File.exist? cache_dir
        file = File.join(cache_dir, TIMESTAMP_FILE)
        FileUtils.touch(file)
      end
    end
  end
end
