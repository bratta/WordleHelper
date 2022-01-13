# frozen_string_literal: true

require 'io/console'

module WordleHelper
  module Util
    def pause_for_user
      puts ''
      puts 'Press any key...'.bright.color(:white)
      user_input = STDIN.getch
      puts ''
      user_input
    end

    def prompt_user(message)
      print "#{message}".bright.color(:white)
      print '>'.bright.color(:red)
      print '>'.bright.color(:green)
      print '> '.bright.color(:blue)
      gets.chomp
    end
  end
end