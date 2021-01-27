PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


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

INSERT INTO
  users (fname, lname)
VALUES
  ("Ned", "Ruggeri"), ("Kush", "Patel"), ("Earl", "Cat");


INSERT INTO
  questions (title, body, user_id)
SELECT
  "Ned Question", "NED NED NED", 1
FROM
  users
WHERE
  users.fname = "Ned" AND users.lname = "Ruggeri";

INSERT INTO
  questions (title, body, user_id)
SELECT
  "Kush Question", "KUSH KUSH KUSH", users.id
FROM
  users
WHERE
  users.fname = "Kush" AND users.lname = "Patel";

INSERT INTO
  questions (title, body, user_id)
SELECT
  "Earl Question", "MEOW MEOW MEOW", users.id
FROM
  users
WHERE
  users.fname = "Earl" AND users.lname = "Cat";


INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  (SELECT id FROM questions WHERE title = "Earl Question")),

  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);


INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  NULL,
  (SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  "Did you say NOW NOW NOW?"
);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"),
  (SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  "I think he said MEOW MEOW MEOW."
);


INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);

-- and here is the lazy way to add some seed data:
INSERT INTO question_likes (user_id, question_id) VALUES (1, 1);
INSERT INTO question_likes (user_id, question_id) VALUES (1, 2);

-- INSERT INTO users 
--   (fname, lname)
-- VALUES
--   ("Stewart", "Morales"),
--   ("Kevin", "Mao");

-- INSERT INTO questions 
--   (title, body, user_id)
-- VALUES
--   ("SM question", "What is a sun?", 
--   (
--     SELECT id
--     FROM users
--     WHERE fname = "Stewart" AND lname = 'Morales'
--   )),
--   ("KM question", "What is a moon?",
--   (
--     SELECT id
--     FROM users
--     WHERE fname = "Kevin" AND lname = 'Mao'
--   ));
