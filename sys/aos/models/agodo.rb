=begin

  agodo.rb

  agodo object.

  by i2097i

=end

require :base64.to_s

class Aos::Agodo < ActiveRecord::Base
  belongs_to :you
  validate :run_validations

  enum :power, [
    :off,
    :on
  ]

  def godo
    godos_per_minute = Aro::Mancy::NUMERALS[:LX].to_f / rate.to_f
    # todo: this is awful
    if Time.now - updated_at >= godos_per_minute
      system("#{:aos} #{self.go} #{Aos::Os::YOU_FLAG} #{self.you.name}")
      system("#{:aos} #{self.do.gsub("_", " ")} #{Aos::Os::YOU_FLAG} #{self.you.name}")
      system("#{:aos} #{self.home.nil? ? "cd" : self.home} #{Aos::Os::YOU_FLAG} #{self.you.name}")
      reload.touch
    end
  end

  def get_lines
    [
      I18n.t(
        "abot.agodo.display",
        power: Aos::Agodo::powers[self.power],
        go: self.go,
        do: self.do,
        rate: self.rate,
        home: self.home.nil? ? "/" : Aos::Os.osify(self.home)
      )
    ]
  end

  def create_home_directory
    Aro::Dom.instance.generate_agodo_home(self)
  end

  def home
    File.join(Aro::Dom.room_path(Aro::Dom::ABOT), Aos::Abot::AGODOS_DIR.to_s, self.you.name)
  end

  private

  def create_you
    # todo: deal with potential name clashes
    self.you = Aos::You.create(
      access: :agodo,
      pwd: Aos::Os.instance.you.pwd,
      name: [
        Aro::T.read_dev_tarot(false),
        Aro::T.summon_ruby_facot(false),
        rand(99..999)
      ].join("_").strip
    )
    self.home = self.you.pwd.split("/").last
    if self.home == Aro::Dom.ethergeist_name
      self.home = nil
    end
    Aro::P.say("spawned agodo named #{you.name}")
  end

  def run_validations
    # validate args
    room_path = Aro::Dom.room_path(self.go)
    unless !room_path.nil? && !room_path.empty?
      errors.add(
        :go,
        :invalid,
        message: I18n.t("abot.messages.invalid_go")
      )
    end

    # unless errors.empty? && Aos::Os.is_aos_command?(self.do)
    #   errors.add(
    #     :do,
    #     :invalid,
    #     message: I18n.t("abot.messages.invalid_do")
    #   )
    # end

    unless errors.empty? && Aos::Cor.int_valid?(self.rate)
      errors.add(
        :rate,
        :invalid,
        message: I18n.t("abot.messages.invalid_rate")
      )
    end

    create_you if self.you.nil? && errors.empty?
  end
end
