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

#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

class User
  attr_accessor :fname, :lname, :id 

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

  def authored_questions
    Questions.find_by_author_id(self.id)
  end 

  def authored_replies
    Replies.find_by_user_id(self.id)
  end 

  def followed_questions 
    QuestionFollows.followed_questions_for_user_id(self.id)
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

#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

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

  def self.find_by_author_id(associated_author)
    data = QuestionsDatabase.instance.execute(<<-SQL, associated_author)
    SELECT 
      * 
    FROM
      questions
    WHERE
      associated_author = ?
    SQL
    return nil if data.length == 0 
    data.map {|datum| Questions.new(datum)}  
  end 

  def initialize(datum)
    @id = datum['id']
    @title = datum['title']
    @body = datum['body'] 
    @associated_author = datum['associated_author']
  end 

  def author
    Users.find_by_id(self.associated_author)
  end 

  def replies
    Replies.find_by_question_id(self.id)
  end 

  def followers 
    QuestionFollows.followers_for_question_id(self.id)
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

#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

class QuestionFollows 
    attr_accessor :user_id, :questions_id
    attr_reader :id 

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

  def self.followers_for_question_id(questions_id)
    u_ids = QuestionsDatabase.instance.execute(<<-SQL, questions_id)
      SELECT 
        user_id
      FROM 
        question_follows
      WHERE 
        questions_id = ?
      SQL
    ans = [] #Array of user object 
    u_ids.each {|u_id| ans << User.find_by_id(u_id['user_id']) } 
    ans 
  end 

  def self.followed_questions_for_user_id(user_id)
    u_ids = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        questions_id
      FROM 
        question_follows
      WHERE 
        user_id = ?
      SQL
    ans = [] #Array of user object 
    u_ids.each {|u_id| ans << Questions.find_by_id(u_id['questions_id']) } 
    ans 
  end 

  def self.most_followed_questions(n)
    m_follow = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.* 
      FROM
        question_follows
      JOIN questions ON questions.id = question_follows.questions_id  
      GROUP BY 
        questions.id 
      ORDER BY
        COUNT(*) DESC
      LIMIT 
        ?
    SQL
    m_follow.map {|qids| Questions.new(qids)}
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
        question_follows(user_id, questions_id)
      VALUES
        (?, ?)
    SQL
  @id = QuestionsDatabase.instance.last_insert_row_id      
  end 

  def update 
    raise '#{self} not in databasse' unless @id 
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @questions_id, @id)
      UPDATE
        question_follows
      SET
        user_id = ?, questions_id = ?
      WHERE
        id = ?
    SQL
  end 
end 

#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

class Replies 
    attr_accessor :question_id, :parent, :user_id, :body, :id

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

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    return nil if data.length == 0 
    Replies.new(data.first)
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    return nil if data.length == 0 
    data.map {|datum| Replies.new(datum)}
  end

  def initialize(datum)
    @id = datum['id']
    @question_id = datum['question_id']
    @parent = datum['parent'] 
    @user_id = datum['user_id']
    @body = datum['body']
  end 

  def author
    User.find_by_id(self.user_id)
  end 

  def question 
    Questions.find_by_id(self.question_id)
  end 

  def parent_reply
    Replies.find_by_id(self.parent)
  end 

  def child_replies 
    child_ids = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        id 
      FROM
        replies
      WHERE
        parent = ?
    SQL
    child_ids.map {|ids| Replies.find_by_id(ids['id'])}
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

#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

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