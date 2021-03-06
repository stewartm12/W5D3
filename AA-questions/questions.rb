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

#####################################################################################################

class Question
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_id(id)
    q = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    Question.new(q.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE user_id = ?
    SQL
    data.map{ |datum| Question.new(datum)} 
  end

  def self.most_followed(n)
    QuestionFollow::most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike::most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def save
    update if id
    QuestionDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO questions (title, body, user_id)
      VALUES (?, ?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE questions
      SET title = ?, body = ?, user_id = ?
      WHERE id = ?
    SQL
  end

  def author 
    User::find_by_id(user_id)
  end

  def replies 
    Reply::find_by_question_id(id)
  end

  def followers
    QuestionFollow::followers_for_question_id(id)
  end

  def likers
    QuestionLike::likers_for_question_id(id)
  end

  def num_likes
    QuestionLike::num_likes_for_question_id(id)
  end
end

################################################################################################

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    u = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    User.new(u.first)
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

  def save
    update if id
    QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO users (fname, lname)
      VALUES (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE users
      SET fname = ?, lname = ?
      WHERE id = ?
    SQL
  end

  def authored_questions
    Question::find_by_author_id(id)
  end

  def authored_replies
    Reply::find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow::followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike::liked_question_for_user_id(id)
  end

  def average_karma
    average = QuestionDBConnection.instance.execute(<<-SQL, id
      SELECT CAST(COUNT(question_id) AS FLOAT)/ COUNT(DISTINCT title) AS average_karma
      FROM questions
      LEFT OUTER JOIN question_likes AS ql
      ON questions.id = ql.question_id
      WHERE questions.user_id = ?
    SQL

    return average.first['average_karma']
  end
end

#########################################################################################

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    qf = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL
    QuestionFollow.new(qf.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM users
      JOIN question_follows
      ON users.id = question_follows.user_id
      WHERE question_follows.question_id = ?
    SQL

    users.map{|user| User.new(user)} 
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM questions
      JOIN question_follows
      ON questions.id = question_follows.question_id
      WHERE question_follows.user_id = ?
    SQL

    questions.map{|q| Question.new(q)} 
  end

  def self.most_followed_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT *
      FROM questions
      JOIN question_follows AS qf
      ON questions.id = qf.question_id
      GROUP BY qf.question_id
      HAVING COUNT(*)
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL

    questions.map{|q| Question.new(q)} 
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

########################################################################################

class Reply
  attr_accessor :id, :body, :parent_id, :user_id, :question_id

  def self.find_by_id(id)
    r = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    Reply.new(r.first)
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

  def save
    update if id
    QuestionDBConnection.instance.execute(<<-SQL, @body, @parent_id, @user_id, @question_id)
      INSERT INTO replies (body, parent_id, user_id, question_id)
      VALUES (?, ?, ?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @body, @parent_id, @user_id, @question_id, @id)
      UPDATE replies
      SET body = ?, parent_id = ?, user_id = ?, question_id = ?
      WHERE id = ?
    SQL
  end

  def author
    User::find_by_id(user_id)
  end 

  def question
    Question::find_by_id(question_id)
  end 
  
  def parent_reply
    Reply::find_by_id(parent_id)
  end

  def child_replies
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
    SELECT *
      FROM replies
      WHERE parent_id = ?
    SQL
    data.map{|datum| Reply.new(datum)} 
  end
end
##################################################################################
class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    ql = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL
    QuestionLike.new(ql.first)
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM users
      JOIN question_likes
      ON users.id = question_likes.user_id
      WHERE question_id = ?
    SQL
    likers.map{|datum| User.new(datum)} 
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*) 
      FROM users
      JOIN question_likes
      ON users.id = question_likes.user_id
      WHERE question_id = ?
    SQL
    return likes.first 
  end

  def self.liked_question_for_user_id(user_id)
    liked = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM questions
      JOIN question_likes
      ON questions.id = question_likes.question_id
      WHERE user_id = ?
    SQL
    liked.map{|datum| User.new(datum)} 
  end

  def self.most_liked_questions(n)
    amount =  QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT *
      FROM questions
      JOIN question_likes AS ql
      ON questions.id = ql.question_id
      GROUP BY ql.question_id
      HAVING COUNT(*)
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    amount.map{|datum| Question.new(datum)} 
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end