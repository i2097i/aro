=begin
  
  t.rb

  tarot.

  by i2097i

=end

module Aro
  module T
    DEV_TAROT_FILE = :"/dev/tarot"
    DEV_TAROT = :"Dev::Tarot".to_s
    RUBY_FACOT = :"Ruby::Facot".to_s

    def self.is_dev_tarot?
      Aro::T.is_dev_tarot_avail? && (
        Aro::Config.ivar(:DIMENSION)&.to_sym ==
        Aro::Config::DMS[:DEV_TAROT]
      )
    end

    def self.is_dev_tarot_avail?
      File.exist?(Aro::T::DEV_TAROT_FILE.to_s)
    end

    # read dev_tarot
    def self.read_dev_tarot(include_o = true)
      dt = nil
      if Aro::T.is_dev_tarot?
        # VERY IMPORTANT!
        File.open(Aro::T::DEV_TAROT_FILE.to_s, "r"){|dtf| dt = dtf.read(Aro::Mancy::N).strip}
        # VERY IMPORTANT!
        Aro::V.say(I18n.t("cli.very_important", dev_tarot: dt))
      else
        Aro::D.say("error: #{Aro::T::DEV_TAROT_FILE.to_s} not installed.")
      end

      if dt.nil?
        # fallback on ruby_facot
        Aro::V.say("warning: summoning ruby_facot in #{__method__}")
        dt = Aro::T.summon_ruby_facot
      end

      return dt[(include_o ? Aro::Mancy::O : Aro::Mancy::S)..]
    end

    # summon ruby_facot
    def self.summon_ruby_facot(include_o = true)
      Aro::D.say(I18n.t("cli.messages.ruby_facot_random"))
      ruby_facot = I18n.t("cards.index").map{|c| "+#{c}"}.sample.split("")

      # get orientation
      rf = ["+","-"].sample

      # get suite
      rf += ruby_facot[1]

      # calculate the sym
      symm = ruby_facot.select{|c|
        # loops through the characters in ruby_facot
        # return all characters not matching:
        # => character[0]: orientation
        # => character[1]: suite 

        # the first two characters in the dev_tarot format designate the
        !ruby_facot.first(Aro::Mancy::OS).include?(c)
      }.join("").to_sym
      rf += Aro::Mancy::NUMERALS[symm].to_s

      # return rf
      return rf[(include_o ? Aro::Mancy::O : Aro::Mancy::S)..]
    end
  end
end