class Bot < ActiveRecord::Base

  def self.search_words words
    CLIENT.search(words, lang: "en").first.text
  end
end

