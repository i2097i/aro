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
      CLI::Config.ivar(:DIMENSION)&.to_sym == CLI::Config::DMS[:DEV_TAROT]
    end

    # read dev_tarot
    def self.read_dev_tarot
      dt = nil
      if Aro::T.is_dev_tarot? && File.exist?(Aro::T::DEV_TAROT_FILE.to_s)
        File.open(Aro::T::DEV_TAROT_FILE.to_s, "r"){|dtf| dt = dtf.read(Aro::Mancy::N)}
        # VERY IMPORTANT!
        Aro::V.say(I18n.t("cli.very_important", dev_tarot: dt))
      else
        Aro::V.say("warning: summoning ruby_facot in #{__method__}")
        dt = Aro::T.summon_ruby_facot unless Aro::T.is_dev_tarot?
      end
      return dt
    end

    # summon ruby_facot
    def self.summon_ruby_facot
      Aro::D.say(I18n.t("cli.messages.ruby_facot_random"))
      ruby_facot = I18n.t("cards.index").map{|c| "+#{c}"}.sample.split("")

      # get orientation
      ruby_facot_str = ["+","-"].sample

      # get suite
      ruby_facot_str += ruby_facot[1]

      # calculate the sym
      symm = ruby_facot.select{|c|
        # loops through the characters in ruby_facot
        # return all characters not matching:
        # => character[0]: orientation
        # => character[1]: suite 

        # the first two characters in the dev_tarot format designate the
        !ruby_facot.first(Aro::Mancy::OS).include?(c)
      }.join("").to_sym
      ruby_facot_str += Aro::Mancy::NUMERALS[symm].to_s

      # return ruby_facot_str
      ruby_facot_str
    end
  end
end