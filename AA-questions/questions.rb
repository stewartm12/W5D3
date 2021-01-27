require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class Question
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    data.map{ |datum| Question.new(datum)} 
  end

  def self.find_by_author_id(author_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE user_id = ?
    SQL
    data.map{ |datum| Question.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    data.map{|datum| User.new(datum)} 
  end

  def self.find_by_name(fname, lname)
    data = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL
    data.map{|datum| User.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question::find_by_author_id(id)
  end
end

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL
    data.map{|datum| QuestionFollow.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Reply
  attr_accessor :id, :body, :parent_id, :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    data.map{|datum| Reply.new(datum)} 
  end

  def self.find_by_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL
    data.map{|datum| Reply.new(datum)} 
  end

  def self.find_by_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL
    data.map{|datum| Reply.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end 
end

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL
    data.map{|datum| QuestionLike.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end