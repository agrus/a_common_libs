module Acl::Patches
  def self.load_all_dependencies
    Dir[File.join(File.dirname(__FILE__), 'patches', '**', '*.rb')].each do |file|
      tmp = File.basename(file, '.rb').gsub(/\_patch$/, '')

      begin
        obj = tmp.camelize.safe_constantize
      rescue LoadError
        obj = nil
      end

      if obj.nil?
        begin
          obj = tmp.upcase.safe_constantize
        rescue LoadError
          obj = nil
        end
      end

      if obj.nil?
        begin
          obj = file.gsub(File.dirname(__FILE__), '').gsub(/\_patch\.rb$/, '').camelize.gsub(/^\:\:Patches\:\:/, '').safe_constantize
        rescue LoadError
          obj = nil
        end
      end

      if obj.nil?
        begin
          obj = file.gsub(File.dirname(__FILE__), '').gsub(/\_patch\.rb$/, '').camelize.gsub(/^\:\:Patches\:\:/, '').gsub("::#{tmp.camelize}", "::#{tmp.upcase}").safe_constantize
        rescue LoadError
          obj = nil
        end
      end

      next unless obj
      obj_patch = File.join('acl', file.gsub(File.dirname(__FILE__), '').gsub(/\.rb$/, '')).camelize.safe_constantize
      next unless obj_patch
      next if obj.included_modules.include?(obj_patch)

      obj.send :include, obj_patch
    end
  end

  load_all_dependencies
end