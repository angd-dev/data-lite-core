 -- This is a single-line comment.
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL
);

/*
   This is a multi-line comment.
   It spans multiple lines and can contain any text.
*/
INSERT INTO users (id, username, email)
VALUES
    (1, 'john_doe', 'john@example.com'), -- Inserting John Doe
    /* This is a comment inside a statement */
    (2, 'jane_doe', 'jane@example.com'); -- Inserting Jane Doe
