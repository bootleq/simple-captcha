require 'digest/sha1'

module SimpleCaptcha #:nodoc
  module Utils #:nodoc
    # Execute command with params and return output if exit status equal expected_outcodes
    def self.run(cmd, params = "", expected_outcodes = 0)
      command = %Q[#{cmd} #{params}].gsub(/\s+/, " ")
      command = "#{command} 2>&1"

      unless (image_magick_path = SimpleCaptcha.image_magick_path).blank?
        command = File.join(image_magick_path, command)
      end

      output = `#{command}`

      unless [expected_outcodes].flatten.include?($?.exitstatus)
        raise ::StandardError, "Error while running #{cmd}: #{output}"
      end

      output
    end

    def self.simple_captcha_value(key) #:nodoc
      SimpleCaptchaData.get_data(key).value rescue nil
    end

    def self.set_simple_captcha_value(key, options={})
      code_type = options[:code_type] || SimpleCaptcha.code_type

      value = generate_value(code_type)
      data = SimpleCaptcha::SimpleCaptchaData.get_data(key)
      data.value = value
      data.save
      key
    end

    def self.generate_value(code)
      value = ''
      code ||= :alpha

      case code
        when :numeric then
          SimpleCaptcha.length.times{value << (48 + rand(10)).chr}
        when :alpha then
          SimpleCaptcha.length.times{value << (65 + rand(26)).chr}
        else
          a = code.chars.to_a
          SimpleCaptcha.length.times{value << (a[rand(a.count)])}
      end

      return value
    end


    def self.simple_captcha_passed!(key) #:nodoc
      SimpleCaptchaData.remove_data(key)
    end

    def self.generate_key(*args)
      args << Time.now.to_s
      Digest::SHA1.hexdigest(args.join)
    end
  end
end
