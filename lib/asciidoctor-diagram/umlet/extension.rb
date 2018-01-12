require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'
require_relative '../util/java_socket'

module Asciidoctor
  module Diagram
    # @private
    module Umlet
      include CliGenerator
      include Which
      include Java

      def self.included(mod)
        [:svg, :png, :pdf, :gif].each do |f|
          mod.register_format(f, :image) do |parent, source|
            umlet(parent, source, f)
          end
        end
      end

      def umlet(parent, source, format)
        umlet_jar= File.expand_path File.join('../..', "umlet-14.2.jar"), File.dirname(__FILE__)
        umlet_cp= File.expand_path '../../umlet-14.2-contrib', File.dirname(__FILE__)
        print("umlet_jar=", umlet_jar, "\n")
        print("umlet_cp=", umlet_cp, "\n")
        java_path= Java.find_java
        print("java=", java_path, "\n")

        generate_file_pp(java_path, 'uxf', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          [java_path, '-Dsun.java2d.xrender=f', '-jar', umlet_jar, '-classpath', umlet_cp, '-action=convert', "-format=#{format.to_s}", "-filename=#{Platform.native_path(input_path)}", "-output=#{Platform.native_path(output_path)}"]
        end
      end
    end

    class UmletBlockProcessor < Extensions::DiagramBlockProcessor
      include Umlet
    end

    class UmletBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Umlet
    end
  end
end
