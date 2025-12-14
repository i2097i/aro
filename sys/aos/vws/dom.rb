=begin
  
  vws/dom.rb

  the dom view.

  by i2097i

=end

require_relative :"./base".to_s

module Aos
  module Vw
    class Dom < Aos::Vw::Base

      def self.show
        lines = []
        lines << I18n.t("aos.views.dom.title")
        lines << I18n.t("aos.views.dom.description")
        lines << ""
        lines << I18n.t("aos.constants.commands")
        lines += lines_for_cmd(Aos::Os::CMDS[:HELP])
        lines << ""
        lines << I18n.t("aos.views.dom.quick_navigation")
        lines << ""
        lines << "  =>  #{Aro::Dom::D.reserved_words.join("  ")}"
        lines << ""
        draw(lines)
      end
    end
  end
end