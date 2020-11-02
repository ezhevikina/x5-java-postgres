--CREATE DATABASE "hw4"
--ENCODING 'UTF8'
--LC_COLLATE = 'en_US.UTF-8'
--LC_CTYPE = 'en_US.UTF-8'
--TEMPLATE template0;

--Создание структуры БД
CREATE TABLE journals (
    id serial PRIMARY KEY,
    title varchar(126) NOT NULL,
    found_year int4 NOT NULL
);


CREATE TABLE articles (
    id serial PRIMARY KEY,
    title varchar(126) NOT NULL,
    published_year int4 NOT NULL,
    journal_id int4 NOT NULL,
    rating numeric CHECK (0 <= rating or rating <= 5),

    CONSTRAINT fk_journal_id
        FOREIGN KEY (journal_id)
        REFERENCES journals(id)
        ON DELETE CASCADE
) PARTITION BY hash (id);

CREATE TABLE articles_0 PARTITION OF articles FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE articles_1 PARTITION OF articles FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE articles_2 PARTITION OF articles FOR VALUES WITH (modulus 3, remainder 2);

CREATE INDEX ON articles (published_year);


CREATE TABLE authors (
    id serial PRIMARY KEY,
    "name" varchar(126) NOT NULL,
    middle_name varchar(126),
    surname varchar(126) NOT NULL
);


CREATE TABLE articles_authors (
    article_id int4 NOT NULL,
    author_id int4 NOT NULL,

    CONSTRAINT articles_authors_pkey
        PRIMARY KEY (article_id, author_id),
    CONSTRAINT articles_authors_article_fkey
        FOREIGN KEY (article_id)
        REFERENCES articles(id)
        ON DELETE CASCADE,
    CONSTRAINT articles_authors_author_fkey
        FOREIGN KEY (author_id)
        REFERENCES authors(id)
        ON DELETE CASCADE
) partition by hash (author_id);

CREATE TABLE articles_authors_0 PARTITION OF articles_authors FOR VALUES WITH (modulus 5, remainder 0);
CREATE TABLE articles_authors_1 PARTITION OF articles_authors FOR VALUES WITH (modulus 5, remainder 1);
CREATE TABLE articles_authors_2 PARTITION OF articles_authors FOR VALUES WITH (modulus 5, remainder 2);
CREATE TABLE articles_authors_3 PARTITION OF articles_authors FOR VALUES WITH (modulus 5, remainder 3);
CREATE TABLE articles_authors_4 PARTITION OF articles_authors FOR VALUES WITH (modulus 5, remainder 4);

CREATE INDEX ON articles_authors (author_id);
CREATE INDEX ON articles_authors (article_id);


-- Заполнение БД информацией
INSERT INTO journals (title, found_year)
VALUES
    ('journal', 2000),
    ('new popular journal', 2019),
    ('old unpopular journal', 1950);

INSERT INTO articles (title, published_year, journal_id, rating)
VALUES
	('article_01', '2020', 2, 5),
	('article_02 about cat', '2020', 2, 3),
	('article_03', '2020', 2, 5),
	('article_04', '2020', 2, NULL),
	('article_05', '2020', 2, 4),
	('article_06', '2020', 2, 5),
	('article_07', '2019', 2, 5),
	('article_08', '2019', 2, 5),
	('article_09', '1990', 3, 5),
	('article_10', '2020', 1, 5),
	('article_11', '2015', 1, 2),
	('article_12', '2000', 1, 4),
	('article_13', '2010', 1, 3),
	('article_14', '2018', 1, 2),
	('article_15 about cat', '2004', 1, 5);

INSERT INTO authors ("name", surname)
VALUES
	('Ivan', 'Ivanov'),
	('Petr', 'Petrov'),
	('Nickolay', 'Nickolaev'),
	('Semen', 'Semenov'),
	('Roman', 'Romanov'),
	('Mihail', 'Mihaylov'),
	('Pavel', 'Pavlov');

INSERT INTO articles_authors (article_id, author_id)
VALUES
	(1, 1), (1, 2), (1, 3), (1, 4),
	(2, 1), (2, 2), (2, 3), (2, 6),
	(3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
	(4, 1), (4, 2),
	(5, 2), (5, 3), (5, 5),
	(6, 2), (6, 3), (6, 4), (6, 5), (6, 6),
	(7, 3),
	(8, 4), (8, 6), (8, 7),
	(9, 1),
	(10, 2), (10, 5),
	(11, 1), (10, 4), (10, 7),
	(12, 5),
	(13, 6),
	(14, 1),
	(15, 1);

-- Выберите все публикации с Годом выхода не позже 2015, рейтингом 3 и более и автором с фамилией "Ivanov".
SELECT a.id, a.title, a.published_year, a.rating, au.surname
FROM articles a
INNER JOIN articles_authors aa ON a.id = aa.article_id
INNER JOIN authors au ON aa.author_id = au.id
WHERE au.surname = 'Ivanov';


-- Выберите все публикации, в названии которых есть слово "cat" и год издания с 2000 по 2005.
SELECT id, title, published_year
FROM articles
WHERE published_year BETWEEN 2000 AND 2005
AND (
	title LIKE '% cat'
	OR title LIKE '% cat %'
	OR title LIKE 'cat %');


-- Выберите все публикации, у которых в авторах есть человек, опубликовавший более 5 статей, и журнал основан более 5 лет назад.
SELECT a.title AS article, aa.author_id, j.title AS journal, j.found_year AS journal_found_year
FROM articles a
INNER JOIN articles_authors aa ON
a.id = aa.article_id
INNER JOIN journals j ON
a.journal_id = j.id
WHERE
	j.found_year < date_part('year', current_date) - 5
	AND aa.author_id IN (
	    SELECT aa.author_id
		FROM articles_authors aa
		GROUP BY aa.author_id
		HAVING count(article_id) > 5)
GROUP BY a.title, aa.author_id, j.title, j.found_year;


-- Выберите все публикации, у которых в авторах есть человек, опубликовавший более 3 статей,
-- и при этом в журнале, в котором они опубликованы, было опубликовано не менее 5 статей за последний год (любыми авторами).
SELECT a.title AS article, j.title AS journal
FROM articles a
INNER JOIN articles_authors aa ON
a.id = aa.article_id
INNER JOIN journals j ON
a.journal_id = j.id
WHERE
	j.id IN (
		SELECT j1.id
		FROM journals j1
		INNER JOIN articles a1 ON j1.id = a1.journal_id
		WHERE a1.published_year = date_part('year', current_date)
		GROUP BY j1.id
		HAVING count(a1.id) >= 5)
	AND aa.author_id IN (
		SELECT aa.author_id
		FROM articles_authors aa
		GROUP BY aa.author_id
		HAVING count(article_id) > 3)
GROUP BY a.title, j.title;


-- Выберите названия журналов, в которых опубликована хотя бы одна статья с рейтингом 4.
SELECT DISTINCT j.title, a.title, a.rating
FROM journals j
INNER JOIN articles a ON j.id = a.journal_id
WHERE a.rating = 4;


-- Выберите названия журналов, в которых была хотя бы одна публикация за последние 5 лет.
SELECT DISTINCT j.title
FROM journals j
INNER JOIN articles a ON j.id = a.journal_id
WHERE a.published_year >= date_part('year', current_date) - 5;


-- Выберите названия журналов, в которых опубликовано не менее 3 статей с рейтингом 3 и более.
SELECT j.title
FROM journals j
INNER JOIN articles a ON j.id = a.journal_id
WHERE a.id IN (
    SELECT id
    FROM articles
    WHERE rating >= 3)
GROUP BY j.title
HAVING count(a.id) >= 3;


-- Выберите информацию: Название журнала, среднее количество авторов публикации.
-- Выберите только те журналы, у которых среднее кол-во авторов публикации 3 и более.
-- Отсортируйте в порядке уменьшения количества авторов.
SELECT j.title, avg(article_authors)
FROM journals j
INNER JOIN articles a ON j.id = a.journal_id
INNER JOIN
	(SELECT article_id, count(author_id) AS article_authors
		FROM articles_authors
		GROUP BY article_id) aa
	ON a.id = aa.article_id
GROUP BY j.title
HAVING avg(article_authors) >= 3
ORDER BY avg(article_authors) DESC;
