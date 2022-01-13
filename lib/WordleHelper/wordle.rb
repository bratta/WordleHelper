# frozen_string_literal: true

# letter_count = {}
# words = File.readlines('/usr/share/dict/words', chomp: true).select!{|x| x.length == 5}
# words.each {|w| w.split('').each {|ltr| letter_count[ltr.downcase] != nil ? letter_count[ltr.downcase] += 1 : letter_count[ltr.downcase] = 1 }}
# letter_count.sort_by {|k,v| -v}

module WordleHelper
  class Wordle
    include WordleHelper::Util
    attr_accessor :word_file, :length, :word_list, :gray_letters, :yellow_letters, :green_letters

    def initialize(length)
      self.word_file = '/usr/share/dict/words'
      self.length = length
      self.gray_letters = Set.new
      self.yellow_letters = Array.new(length)
      self.green_letters = Array.new(length)

      init_word_list
    end

    def init_word_list
      @word_list = File.readlines(@word_file, chomp: true).select!{|word| word.length == @length}
    end

    def add_gray(gray_letters)
      gray_letters.split('').each {|ltr| @gray_letters.add(ltr)}
    end

    def add_yellow(yellow_letter, position)
      if (position < 0 || position > @length-1)
        puts "Invalid position!".bright.color(:red)
      else
        if @yellow_letters[position] != nil
          @yellow_letters[position] << yellow_letter
        else
          @yellow_letters[position] = [yellow_letter]
        end
      end
    end

    def add_green(green_letter, position)
      if (position < 0 || position > @length-1)
        puts "Invalid position!".bright.color(:red)
      else
        @green_letters[position] = green_letter
      end
    end

    def input_gray
      letters = prompt_user("Enter any gray letters (no spaces or separators). ")
      add_gray(letters)
    end

    def input_yellow
      letters = prompt_user("Enter letters followed by position (eg. e4r5 for yellow E in position 4, R in position 5). ")
      yellows = letters.split(/(\d+)/).each_slice(2).to_a
      if (yellows.any? {|y| y.length != 2 })
        puts 'Invalid entry. You need a letter followed by a position (eg. e4r5).'.bright.color(:red)
      elsif (yellows.map {|y| y[1].to_i }.any? {|y| y < 1 || y > @length})
        puts 'Invalid position detected.'.bright.color(:red)
      else
        yellows.each {|y| add_yellow(y[0], y[1].to_i-1)}
      end
    end

    def input_green
      letters = prompt_user("Enter letters followed by position (eg. e4r5 for green E in position 4, R in position 5). ")
      greens = letters.split(/(\d+)/).each_slice(2).to_a
      if (greens.any? {|y| y.length != 2 })
        puts 'Invalid entry. You need a letter followed by a position (eg. e4r5).'.bright.color(:red)
      elsif (greens.map {|y| y[1].to_i }.any? {|y| y < 1 || y > @length})
        puts 'Invalid position detected.'.bright.color(:red)
      else
        greens.each {|y| add_green(y[0], y[1].to_i-1)}
      end
    end

    def show_current
      puts "Gray: #{@gray_letters.join(' ')}".bright.color(:gray)
      print "Yellow: ".bright.color(:yellow)
      @yellow_letters.each_with_index do |letters, position|
        print "#{position+1}:#{letters.join(',')} " if letters
      end
      puts ''
      print "Green: ".bright.color(:green)
      @green_letters.each_with_index do |letter, position|
        print "#{position+1}:#{letter} " if letter
      end
      puts ''
    end

    def show_suggested
      suggested = filter_grays(@word_list);
      suggested = filter_yellows(suggested);
      suggested = has_letters_at_position(suggested, @green_letters) unless @green_letters.compact.empty?
      suggested = does_not_have_letters_at_position(suggested, @yellow_letters) unless @yellow_letters.compact.empty?
      puts "Suggested words:\n#{suggested.join(', ')}".color(:gray)
      puts ''
    end

    def filter_grays(word_list)
      if @gray_letters.empty?
        return word_list
      else
        word_list.filter{|w| !w[/[#{Regexp.quote(@gray_letters.join(''))}]+/i] }
      end
    end

    def filter_yellows(word_list)
      letter_array = @yellow_letters.flatten.compact
      if letter_array.empty?
        return word_list
      else
        letter_array.map! {|x| "(?=.*#{x})"}
        word_list.filter {|w| w[/#{letter_array.join('')}/i] }
      end
    end

    def has_letters_at_position(word_list, positional_array)
      word_list.filter { |word| has_all_letters_in_position?(word, positional_array) }
    end

    def does_not_have_letters_at_position(word_list, positional_array)
      word_list.filter do |word|
        !word_includes_letters_at_position(word, positional_array)
      end
    end

    def word_includes_letters_at_position(word, positional_array)
        positional_array.filter_map.with_index do |letters, position|
          letters = letters.is_a?(Array) ? letters : [letters]
          letters.any?(word[position]) if word[position]
        end.compact.uniq[0]
    end

    def has_all_letters_in_position?(word, positional_array)
      positional_array.each_with_index do |letters, position|
        letters = letters.is_a?(Array) ? letters : [letters]
        unless letters.empty?
          letters.each do |letter|
            next unless letter
            return false if word[position].downcase != letter
          end
        end
      end
      return true
    end
  end
end