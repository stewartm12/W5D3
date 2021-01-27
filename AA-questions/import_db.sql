PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT, 
  user_id INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  parent_id INTEGER,
  user_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO users 
  (fname, lname)
VALUES
  ("Stewart", "Morales"),
  ("Kevin", "Mao");

INSERT INTO questions 
  (title, body, user_id)
VALUES
  ("SM question", "What is a sun?", 
  (
    SELECT id
    FROM users
    WHERE fname = "Stewart" AND lname = 'Morales'
  )),
  ("KM question", "What is a moon?",
  (
    SELECT id
    FROM users
    WHERE fname = "Kevin" AND lname = 'Mao'
  ));