=begin
  
  views/dom.rb

  the dom view.

  by i2097i

=end

require_relative :"./base".to_s

module Aos
  module Vi
    class Dom < Aos::Vi::Base

      def self.show(model)
        lines = []
        lines << I18n.t("aos.views.dom.title")
        lines << I18n.t("aos.views.dom.description")
        lines << ""
        lines << I18n.t("aos.constants.commands")
        Aos::Os::CMDS.keys.sort.each{|cmd|
          lines += lines_for_cmd(Aos::Os::CMDS[cmd])
        }

        lines << ""
        lines << I18n.t("aos.views.dom.quick_navigation")
        lines << ""
        lines << "  =>  #{Aro::Dom::D.reserved_words.join("  ")}"
        lines << ""
        draw(lines, model)
      end
    end
  end
end