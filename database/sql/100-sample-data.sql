/* Script for populating the database with sample speaker and session data. */

/* SPEAKERS */
-- Insert sample speaker data into the web.speakers table.
-- The require_embeddings_update column is set to 1 to indicate that embeddings need to be generated for these speakers.
INSERT INTO web.speakers (id, full_name, require_embeddings_update) 
VALUES 
    (5000, 'John Doe', 1),
    (5001, 'Jane Smith', 1);
GO

-- Generate embeddings for the speakers' full name.
DECLARE @id int, @full_name NVARCHAR(max), @embeddings vector(1536);

DECLARE speaker_cursor CURSOR FOR
SELECT id, full_name FROM web.speakers WHERE require_embeddings_update = 1;

OPEN speaker_cursor;
FETCH NEXT FROM speaker_cursor INTO @id, @full_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC web.get_embedding @full_name, @embeddings OUTPUT;
    UPDATE web.speakers
    SET 
        embeddings = @embeddings,
        require_embeddings_update = 0
    WHERE id = @id;

    FETCH NEXT FROM speaker_cursor INTO @id, @full_name;
END;
CLOSE speaker_cursor;
DEALLOCATE speaker_cursor;
GO

/* SESSIONS */
-- Insert sample session data into the web.sessions table.
-- The require_embeddings_update column is set to 1 to indicate that embeddings need to be generated for these sessions.
INSERT INTO web.sessions (id, title, abstract, external_id, start_time, end_time, require_embeddings_update)
VALUES
    (
        1000,
        'Building a session recommender using OpenAI and Azure SQL', 
        'In this fun and demo-driven session you''ll learn how to integrate Azure SQL with OpenAI to generate text embeddings, store them in the database, index them and calculate cosine distance to build a session recommender. And once that is done, you''ll publish it as a REST and GraphQL API to be consumed by a modern JavaScript frontend. Sounds pretty cool, uh? Well, it is!',
        'S1',
        '2024-06-01 10:00:00',
        '2024-06-01 11:00:00',
        1
    ),
    (
        1001,
        'Unlock the Art of Pizza Making with John Doe!', 
        'Whether you''re an avid home pizza oven enthusiast, contemplating a purchase, or nurturing dreams of launching your very own pizza venture, this course is tailor-made for you! Join John Doe, the visionary behind Great Pizza, as he guides you through the captivating world of pizza craftsmanship. With over six years of experience running his thriving pizza business, John has honed his skills to perfection, earning the title of a master pizzaiolo. Before embarking on his entrepreneurial journey, John—a former chef—also completed a pizza-making course at The School. Now, he''s excited to share his expertise with you in this hands-on workshop. During the course, you''ll learn to create three distinct pizza styles: Neapolitan, thin Roman “Tonda,” and Calzone. Dive into the art of dough preparation, experimenting with both high and low hydration doughs, all while adjusting temperatures to achieve pizza perfection. Don''t miss this opportunity to elevate your pizza-making game and impress your taste buds! ',
        'S2',
        '2024-06-01 11:00:00',
        '2024-06-01 12:00:00',
        1
    ),
    (
        1002,
        'RAG on Azure SQL', 
        'RAG (Retrieval Augmented Generation) is the most common approach used to get LLMs to answer questions grounded in a particular domain''s data. How do you build a RAG solution on data already stored in SQL Server or Azure SQL? In this session you''ll learn about existing and future options that you can start to use right tomorrow, leveraging Azure SQL as a vector store and taking advantage of its established performances, security and enterprise readiness!',
        'R1',
        '2024-09-05 16:00:00',
        '2024-09-05 17:00:00',
        1
    ),
    (
        1003,
        'Bring your own data with OpenAI',
        'In this session you''ll learn how to use your own private data with OpenAI. We''ll cover the basics of how to retrieve data from an Azure SQL database, how to use it with OpenAI using the RAG pattern, and some best practices improving performance when performing retrieval-augmented generation (RAG).',
        'R2',
        '2024-09-05 14:00:00',
        '2024-09-05 15:00:00',
        1
    );
GO

-- Generate embeddings for the sessions' title and abstract.
-- The embeddings are stored in the embeddings column, and the require_embeddings_update column is set to 0 to indicate that embeddings have been generated.
DECLARE @id int, @title NVARCHAR(max), @abstract NVARCHAR(max), @text_to_embed NVARCHAR(max), @embeddings vector(1536);

DECLARE session_cursor CURSOR FOR
SELECT id, title, abstract FROM web.sessions WHERE require_embeddings_update = 1;

OPEN session_cursor;
FETCH NEXT FROM session_cursor INTO @id, @title, @abstract;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @text_to_embed = @title + ':' + @abstract; -- Concatenate title and abstract for embedding generation
    EXEC web.get_embedding @text_to_embed , @embeddings OUTPUT;
    UPDATE web.sessions
    SET 
        embeddings = @embeddings,
        require_embeddings_update = 0
    WHERE id = @id;

    FETCH NEXT FROM session_cursor INTO @id, @title, @abstract;
END;
CLOSE session_cursor;
DEALLOCATE session_cursor;
GO

/* SPEAKERS SESSIONS */
-- Insert sample data into the web.sessions_speakers table to establish a many-to-many relationship between sessions and speakers.
TRUNCATE TABLE web.sessions_speakers; -- Clear existing data in the sessions_speakers table
GO
INSERT INTO web.sessions_speakers (session_id, speaker_id)
VALUES
    (1000, 5000), -- John Doe and Jane Smith are speakers for session 1000
    (1001, 5000), -- John Doe is a speaker for session 1001
    (1002, 5000), -- John Doe is a speaker for session 1002
    (1002, 5001), -- Jane Smith is a speaker for session 1002
    (1003, 5001); -- Jane Smith is a speaker for session 1003
GO
