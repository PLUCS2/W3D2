PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY, 
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  associated_author INTEGER, 
  FOREIGN KEY (associated_author) REFERENCES users(id) 
); 

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL, 
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL, 
  parent INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (parent) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)   
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL, 
  FOREIGN KEY (user_id) REFERENCES users(id), 
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
  users(fname, lname)
VALUES 
  ("Paloma", "Secunda"),
  ("Jess", "Fleischer"),
  ("Alvin", "Zablan");


INSERT INTO 
  questions(title, body, associated_author)
VALUES 
  ("computer", "What is a computer?", (SELECT id FROM users WHERE fname = "Jess" AND lname = "Fleischer")),
  ("calabasas", "Where are the Kardashians?", (SELECT id FROM users WHERE fname = "Paloma")),
  ("New York", "Where are chipotles?", (SELECT id FROM users WHERE fname = "Alvin"));

INSERT INTO 
  question_follows(user_id, questions_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Jess"), (SELECT id FROM questions WHERE title = "computer")),
  ((SELECT id FROM users WHERE fname = "Paloma"), (SELECT id FROM questions WHERE title = "calabasas")),
  ((SELECT id FROM users WHERE fname = "Alvin"), (SELECT id FROM questions WHERE title = "New York"));

INSERT INTO
  replies(question_id, parent, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "computer"), NULL, (SELECT id FROM users WHERE fname = "Paloma"), "A machine!!!"), 
  ((SELECT id FROM questions WHERE title = "New York"), NULL, (SELECT id FROM users WHERE fname = "Alvin"), "in ur heart!!"),
  ((SELECT id FROM questions WHERE title = "calabasas"), 1, (SELECT id FROM users WHERE fname = "Jess"), "on vacation"),
  ((SELECT id FROM questions WHERE title = "New York"), NULL, (SELECT id FROM users WHERE fname = "Paloma"), "bryant park??");

INSERT INTO 
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Paloma"), (SELECT id FROM questions WHERE title = "calabasas")),
  ((SELECT id FROM users WHERE fname = "Alvin"), (SELECT id FROM questions WHERE title = "New York")),
  ((SELECT id FROM users WHERE fname = "Jess"), (SELECT id FROM questions WHERE title = "computer"));




