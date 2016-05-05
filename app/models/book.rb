class Book < ActiveRecord::Base

def self.parse_table(filename)
  table = []
  file = File.open(filename)
  file.each do |line|
    if line == "\n"
      table << "\n"
      table << "\n"
    else
      words = line.split(" ")
      words.each do |word|
        table << word
      end
    end
  end
  table
end

def self.build_lookup name words
  lookup = {}
  word_1 = "\n"
  word_2 = "\n"
  words.each do |nextword|
    nextword.delete!("\"")
    nextword.delete!("(")
    nextword.delete!(")")
    key = Book.keymaker(word_1, word_2)
    if mostly_letters?([word_1, word_2, nextword])
      if lookup[key] == nil
        lookup[key] = [nextword]
      elsif lookup[key].class == Array
        lookup[key] << nextword
      else
        raise "error in building lookup"
      end
    end
    word_1 = word_2
    word_2 = nextword
  end
  Book.create(name: name, book_text: lookup)
  lookup
end

def self.make_sentence(lookups)
  sentence = ""
  word_1 = "\n"
  word_2 = "\n"
  next_word = "\n" #["It", "The", "If", "They", "We", "What", "Do", "Is", "This", "A", "Giants"].sample
  source_preference = rand(lookups.length-1)

  source_counter = []
  lookups.length.times do
    source_counter << 0
  end

  current_lookup = lookups[source_preference]
  loop_counter = 0
  until Book.end_of_sentence?(next_word)
    loop_counter += 1
    key = keymaker(word_1, word_2)

    #check if we need to change the source
    if source_counter[source_preference] >= source_counter.min + 3
      #change to least used source if possible
      bestfit_lookup_index = source_counter.index(source_counter.min)
      wildcard_lookup_index = rand(lookups.length - 1)

      if lookups[bestfit_lookup_index][key] != nil
        source_preference = bestfit_lookup_index
        current_lookup = lookups[source_preference]
        puts "changed source to bestfit " + source_preference.to_s
        puts sentence
      elsif lookups[wildcard_lookup_index][key] != nil
        source_preference = wildcard_lookup_index
        current_lookup = lookups[wildcard_lookup_index]
        # puts "changed source to wildcard " + source_preference.to_s
        # puts sentence
      end
    end

    if current_lookup[key] != nil
      source_counter[source_preference] += 1
      next_word = current_lookup[key].sample
      sentence = sentence + " " + next_word if next_word != "\n"
    end
    word_1 = word_2
    word_2 = next_word
    break if word_1 + word_2 + next_word == "\n\n\n"

    if loop_counter >= 100
      # puts "we are over loop counter: " + word_1 + " " + word_2 + " " + next_word
      break
    end
  end

  return sentence[1..-1] if sentence.length > 15 # chuck out the sentence if it's too short
  # puts "sentence was too short"
  Book.make_sentence(lookups)
end

def self.end_of_sentence?(word)
  return false if ["Mr.", "Ms.", "Mrs.", "Dr."].include?(word)
  return true if SENTENCE_END_CHARS.include?(word[-1])
  false
end


end
