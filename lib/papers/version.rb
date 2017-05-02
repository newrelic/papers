module Papers
  class Version
    MAJOR = 2
    MINOR = 4
    PATCH = 2

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Version.to_s
end

