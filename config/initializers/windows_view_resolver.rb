# Ruby on Windows does not match files when Dir.glob receives an absolute
# drive-letter path (for example, C:/project/app/views/**/*.erb). Rails' file
# system view resolver uses that form, so convert the glob to a path relative
# to the current directory before searching.
if Gem.win_platform?
  module WindowsRelativeTemplateGlob
    private

    def template_glob(glob)
      absolute_query = File.join(escape_entry(@path), glob)
      relative_query = Pathname.new(absolute_query).relative_path_from(Pathname.new(Dir.pwd)).to_s
      path_with_slash = File.join(@path, "")

      Dir.glob(relative_query).filter_map do |filename|
        filename = File.expand_path(filename)
        next if File.directory?(filename)
        next unless filename.start_with?(path_with_slash)

        filename
      end
    end
  end

  ActionView::FileSystemResolver.prepend(WindowsRelativeTemplateGlob)
end
