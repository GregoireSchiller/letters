require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @block = block = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now.to_i
  end

  def score
    @answer = params[:answer]
    @start_time = params[:start_time].to_i
    @block = params[:block].split('')
    @end_time = Time.now.to_i
    @time_taken = @end_time - @start_time
    @translation = get_translation(@answer)
    @score_and_message = score_and_message(@answer, @translation, @block, @time_taken)
  end

  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word}")
    json = JSON.parse(response.read.to_s)
    @translation = json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

  def included?(guess, grid)
  the_grid = grid.clone
  guess.chars.each do |letter|
    the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
  end
  grid.size == guess.size + the_grid.size
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, translation, grid, time)
  if translation
    if included?(attempt.upcase, grid)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
  end

end
