# frozen_string_literal: true

module WordleHelper
  class CLI
    include WordleHelper::Util
    attr_accessor :wordle
    def call
      puts 'WORDLE HELPER'.bright.color(:green)
      puts ''
      wordle_length = 0
      while (wordle_length == 0)
        wordle_length_input = prompt_user('How many letters in the word? ')
        wordle_length = wordle_length_input.to_i
        wordle_length = 0 if (wordle_length < 0 || wordle_length > 10)
      end
      puts "Word length is set to #{wordle_length}...".bright.color(:blue)
      puts "Now make your first guess.".bright.color(:blue)
      puts ''
      @wordle = WordleHelper::Wordle.new(wordle_length)
      do_loop
    end

    def do_loop
      menu_option = 0
      choice = show_menu
      loop do
        menu_option = choice.to_i
        if menu_option == 999
          require 'debug'
          binding.b
        end
        menu_option = 0 if (menu_option < 0 || menu_option > 6)
        break if menu_option == 6
        handle_input(menu_option) if menu_option > 0
        choice = show_menu
      end

      puts "See ya!".bright.color(:green)
    end

    def show_menu
      print '1'.bright.color(:gray)
      puts '. Enter "' + 'grey'.bright.color(:gray) + '" letters not in the word.'.bright.color(:white)
      print '2'.bright.color(:yellow)
      puts '. Enter "' + 'yellow'.bright.color(:yellow) + '" letters in the word and in the incorrect space.'.bright.color(:white)
      print '3'.bright.color(:green)
      puts '. Enter "' + 'green'.bright.color(:green) + '" letters in the word and in the correct space.'.bright.color(:white)
      print '4'.bright.color(:blue)
      puts '. Show current letters.'.bright.color(:white)
      print '5'.bright.color(:blue)
      puts '. Show suggested words based on current progress.'.bright.color(:white)
      print '6'.bright.color(:red)
      puts '. Quit this application.'.bright.color(:white)
      prompt_user('[123456] What do you do? ')
    end

    def handle_input(option)
      case option
      when 1
        @wordle.input_gray
      when 2
        @wordle.input_yellow
      when 3
        @wordle.input_green
      when 4
        @wordle.show_current
      when 5
        @wordle.show_suggested
      end
    end
  end
end