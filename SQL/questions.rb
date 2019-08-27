require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true 
    self.results_as_hash = true 
  end 
end 


class User
  attr_accessor :fname, :lname 

  def self.all 
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end 

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT 
      * 
    FROM
      users
    WHERE
      id = ?
    SQL
    return nil if data.length == 0 
    User.new(data.first)
  end 

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT 
      * 
    FROM 
      users 
    WHERE 
      fname = ? 
      AND lname = ?
    SQL
    return nil if data.length == 0
    User.new(data.first)
  end

  def initialize(datum)
    @id = datum['id']
    @fname = datum['fname']
    @lname = datum['lname'] 
  end 

  def create
    raise '#{self} already in datacase' if @id 
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO 
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @id, @fname, @lname)
      UPDATE
        users
      SELECT
        @fname = ? , @lname = ?
      WHERE
        @id = ?
    SQL
  end 
end

class Questions
  attr_accessor :title, :body, :associated_author 

  def self.all 
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end 
    def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT 
      * 
    FROM
      questions
    WHERE
      id = ?
    SQL
    return nil if data.length == 0 
    Questions.new(data.first)
  end 

  def initialize(datum)
    @id = datum['id']
    @title = datum['title']
    @body = datum['body'] 
    @associated_author = datum['associated_author']
  end 

  def create
    raise '#{self} already in datacase' if @id 
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @associated_author)
      INSERT INTO 
        users(title, body, associated_author)
      VALUES
        (?, ?, ?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @id, @title, @body, @associated_author)
      UPDATE
        users
      SELECT
        @title = ?, @body = ?, @associated_author = ?
      WHERE
        @id = ?
    SQL
  end 
end 

class QuestionFollows 
    attr_accessor :user_id, :questions_id

  def self.all 
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollows.new(datum) }
  end 

    def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT 
      * 
    FROM
      question_follows
    WHERE
      id = ?
    SQL
    return nil if data.length == 0 
    QuestionFollows.new(data.first)
  end 

  def initialize(datum)
    @id = datum['id']
    @user_id = datum['user_id']
    @questions_id = datum['questions_id'] 
  end 

  def create
    raise '#{self} already in datacase' if @id 
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @questions_id)
      INSERT INTO 
        users(user_id, questions_id)
      VALUES
        (?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @id, @user_id, @questions_id)
      UPDATE
        users
      SELECT
        @user_id = ?, @questions_id = ?
      WHERE
        @id = ?
    SQL
  end 
end 

class Replies 
    attr_accessor :question_id, :parent, :user_id, :body 

  def self.all 
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end 

    def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      id = ?
    SQL
    return nil if data.length == 0 
    Replies.new(data.first)
  end 

  def initialize(datum)
    @id = datum['id']
    @question_id = datum['question_id']
    @parent = datum['parent'] 
    @user_id = datum['user_id']
    @body = datum['body']
  end 

  def create
    raise '#{self} already in datacase' if @id 
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent, @user_id, @body)
      INSERT INTO 
        users(question_id, parent, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @id, @question_id, @parent, @user_id, @body)
      UPDATE
        users
      SELECT
        @question_id = ?, @parent = ?, @user_id = ?, @body = ?
      WHERE
        @id = ?
    SQL
  end 
end 

class QuestionLikes 
    attr_accessor :user_id, :question_id

  def self.all 
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end 

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT 
      * 
    FROM
      question_likes
    WHERE
      id = ?
    SQL
    return nil if data.length == 0 
    QuestionLikes.new(data.first)
  end 

  def initialize(datum)
    @id = datum['id']
    @user_id = datum['user_id']
    @question_id = datum['question_id'] 
  end 

  def create
    raise '#{self} already in datacase' if @id 
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO 
        users(user_id, question_id)
      VALUES
        (?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @id, @user_id, @question_id)
      UPDATE
        users
      SELECT
        @user_id = ?, @question_id = ?
      WHERE
        @id = ?
    SQL
  end 
end 