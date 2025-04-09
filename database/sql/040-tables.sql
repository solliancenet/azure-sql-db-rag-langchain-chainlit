/*
    This script creates the tables for the web application, including the searched_text, sessions,
    speakers, and sessions_speakers tables.
*/

/*
    Table name: searched_text
    Description: 
        This table stores the searched text, the date and time of the search, and the performance
        metrics for the search.
*/
DROP TABLE IF EXISTS [web].[searched_text];
GO
DROP TABLE IF EXISTS [web].[sessions_speakers];
GO
DROP TABLE IF EXISTS [web].[speakers];
GO
DROP TABLE IF EXISTS [web].[sessions];
GO

CREATE TABLE [web].[searched_text]
(
    [id] INT IDENTITY (1, 1) NOT NULL,
    [searched_text] NVARCHAR (MAX) NOT NULL,
    [search_datetime] DATETIME2 (7) DEFAULT (sysdatetime()) NOT NULL,
    [ms_rest_call] INT NULL,
    [ms_vector_search] INT NULL,
    [found_sessions] INT NULL,

    PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

/*
    Table name: sessions
    Description: 
        This table stores the session information, including the title, abstract, external ID,
        last fetched date and time, start and end times, tags, recording URL, and embeddings.
*/
CREATE TABLE [web].[sessions]
(
    [id] INT DEFAULT (NEXT VALUE FOR [web].[global_id]) NOT NULL,
    [title] NVARCHAR (200) NOT NULL,
    [abstract] NVARCHAR (MAX) NOT NULL,
    [external_id] VARCHAR (100) COLLATE Latin1_General_100_BIN2 NOT NULL,
    [last_fetched] DATETIME2 (7) NULL,
    [start_time] DATETIME2 (0) NOT NULL,
    [end_time] DATETIME2 (0) NOT NULL,
    [tags] NVARCHAR (MAX) NULL,
    [recording_url] VARCHAR (1000) NULL,
    [require_embeddings_update] BIT DEFAULT ((0)) NOT NULL,
    [embeddings] VECTOR(1536) NULL,

    PRIMARY KEY CLUSTERED ([id] ASC),
    CHECK (isjson([tags])=(1)),
    UNIQUE NONCLUSTERED ([title] ASC)
);
GO

/*
    Table name: speakers
    Description: 
        This table stores the speaker information, including the external ID, full name,
        require_embeddings_update flag, and embeddings.
*/
CREATE TABLE [web].[speakers]
(
    [id] INT DEFAULT (NEXT VALUE FOR [web].[global_id]) NOT NULL,
    [external_id] VARCHAR (100) COLLATE Latin1_General_100_BIN2 NULL,
    [full_name] NVARCHAR (100) NOT NULL,
    [require_embeddings_update] BIT DEFAULT ((0)) NOT NULL,
    [embeddings] VECTOR(1536) NULL,

    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([full_name] ASC)    
);
GO

/*
    Table name: sessions_speakers
    Description: 
        This table establishes a many-to-many relationship between sessions and speakers.
        It contains the session ID and speaker ID as foreign keys.
*/
CREATE TABLE [web].[sessions_speakers] (
    [session_id] INT NOT NULL,
    [speaker_id] INT NOT NULL,

    PRIMARY KEY CLUSTERED ([session_id] ASC, [speaker_id] ASC),
    CONSTRAINT fk__sessions_speakers__sessions FOREIGN KEY ([session_id]) REFERENCES [web].[sessions] ([id]),
    CONSTRAINT fk__sessions_speakers__speakers FOREIGN KEY ([speaker_id]) REFERENCES [web].[speakers] ([id])
);
GO

/* 
    Create non-clustered indexes on the sessions_speakers tables to improve query performance.
*/
CREATE NONCLUSTERED INDEX [ix2]
    ON [web].[sessions_speakers]([speaker_id] ASC);
GO

ALTER TABLE [web].[sessions] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);
GO

ALTER TABLE [web].[speakers] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);
GO

