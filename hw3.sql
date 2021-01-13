--CREATE DATABASE hw3
--ENCODING 'UTF8'
--LC_COLLATE = 'en_US.UTF-8'
--LC_CTYPE = 'en_US.UTF-8'
--TEMPLATE template0;

-- Написать скрипт создания таблиц с правильными типами полей
-- Создать правильные связи между таблицами
CREATE TABLE courses (
    id serial PRIMARY KEY,
    title varchar(126) NOT NULL,
    start date NOT NULL,
    "end" date NOT NULL
);

CREATE TABLE students (
    id serial PRIMARY KEY,
    "name" varchar(126) NOT NULL,
    last_name varchar(126) NOT NULL,
    birth_date date NOT NULL,
    email varchar(126) NOT NULL
);

CREATE TABLE student_courses (
    student_id int4 NOT NULL,
    course_id int4 NOT NULL,

    CONSTRAINT student_courses_pkey
        PRIMARY KEY (student_id, course_id),
    CONSTRAINT student_courses_student_fkey
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE,
    CONSTRAINT student_courses_tag_fkey
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);

CREATE TABLE lectures (
    id serial PRIMARY KEY,
    title varchar(126) NOT NULL,
    scheduled_date date NOT NULL,
    course_id int4 NOT NULL,

    CONSTRAINT fk_course_id
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);



-- Создать данные для вставки в таблицы. 10 студентов, 5 курсов, ~15 лекций (по одной / две / три на курс),
-- запись как минимум на один курс для каждого студента. Максимум - можно записаться на все
INSERT INTO courses (title, start, "end")
VALUES
    ('Java', '2020-11-01', '2020-12-30'),
    ('Python', '2020-11-01', '2020-12-30'),
    ('DevOps', '2020-11-01', '2020-12-30'),
    ('Testing', '2020-11-01', '2020-12-30'),
    ('Общий', '2020-09-01', '2020-10-31');

INSERT INTO students ("name", last_name, birth_date, email)
VALUES
    ('Студент', 'Первый', '2000-10-31', 'student1@qq.qq'),
    ('Студент', 'Второй', '1979-09-15', 'student2@qq.qq'),
    ('Студент', 'Третий', '1987-11-01', 'student3@qq.qq'),
    ('Студент', 'Четвертый', '1993-10-10', 'student4@qq.qq'),
    ('Студент', 'Пятый', '2001-08-22', 'student5@qq.qq'),
    ('Студент', 'Шестой', '1995-02-21', 'student6@qq.qq'),
    ('Студент', 'Седьмой', '1995-02-21', 'student7@qq.qq'),
    ('Студент', 'Восьмой', '1989-02-03', 'student8@qq.qq'),
    ('Студент', 'Девятый', '1985-12-07', 'student9@qq.qq'),
    ('Студент', 'Десятый', '1987-08-07', 'student10@qq.qq');

INSERT INTO student_courses (student_id, course_id)
VALUES
    (1, 1), (1, 4), (1, 5),
    (2, 4), (2, 5),
    (3, 2), (3, 3), (3, 5),
    (4, 1), (4, 5),
    (5, 2), (5, 4), (5, 5),
    (6, 2), (6, 5),
    (7, 1), (7, 4), (7, 5),
    (8, 1), (8, 3), (8, 5),
    (9, 5),
    (10, 1), (10,5);

INSERT INTO lectures (title, scheduled_date, course_id)
VALUES
    ('Java 1', '2020-11-01', 1),
    ('Java 2', '2020-12-01', 1),
    ('Java 3', '2020-12-30', 1),
    ('Python 1', '2020-11-01', 2),
    ('Python 2', '2020-12-01', 2),
    ('Python 3', '2020-12-30', 2),
    ('DevOps 1', '2020-11-01', 3),
    ('DevOps 2', '2020-12-30', 3),
    ('Testing 1', '2020-11-01', 4),
    ('Testing 2', '2020-12-30', 4),
    ('Общий 1', '2020-09-01', 5),
    ('Общий 2', '2020-09-15', 5),
    ('Общий 3', '2020-10-01', 5),
    ('Общий 4', '2020-10-15', 5),
    ('Общий 5', '2020-10-31', 5);


CREATE VIEW student_courses_lectures AS
SELECT
    s.id AS student_id,
    s."name" AS student_name,
    s.last_name AS student_last_name,
    s.email AS student_email,
    s.birth_date AS student_bday,
    sc.course_id AS course_id,
    l.id AS lecture_id,
    l.title AS lecture_title
FROM students s
    LEFT JOIN student_courses sc ON s.id = sc.student_id
    LEFT JOIN lectures l ON sc.course_id = l.course_id;


-- Сделать выборку: сколько всего лекций послушает каждый студент
SELECT student_id, student_name, student_last_name, count(lecture_id) AS lectures
FROM student_courses_lectures
GROUP BY student_id, student_name, student_last_name
ORDER BY student_id;



-- Найти самые популярные лекции, которые увидит больше всего студентов
SELECT lecture_title, count(student_id) AS students_visiting
FROM student_courses_lectures
GROUP BY lecture_title
ORDER BY students_visiting DESC, lecture_title
LIMIT 7;



-- Найти наименее популярные лекции, которые увидит больше всего студентов
SELECT *
FROM (
    SELECT lecture_title, count(student_id) AS students_visiting
    FROM student_courses_lectures
    GROUP BY lecture_title
    ORDER BY students_visiting, lecture_title
    LIMIT 7) AS unpopular
ORDER BY students_visiting DESC;



-- Сделайте запрос с подзапросом, который выберет лекции, которые популярней среднего значения
WITH attendance AS (
    SELECT lecture_title, count(student_id) AS students_visiting
    FROM student_courses_lectures
    GROUP BY lecture_title
)
SELECT *
FROM attendance
WHERE students_visiting > (
    SELECT avg(students_visiting)
    FROM attendance
)
ORDER BY students_visiting DESC, lecture_title;



-- Выбрать все лекции, которые пройдут в рамках курсов, которые стартуют в текущем году
SELECT DISTINCT l.title
FROM lectures l
LEFT JOIN student_courses sc ON l.course_id = sc.course_id
LEFT JOIN courses c ON sc.course_id = c.id
WHERE date_trunc('year', c.start) = date_trunc('year', now());



-- Выберете средний год рождения студентов для каждого курса
SELECT course_id, FLOOR(AVG(EXTRACT(year FROM student_bday)))
FROM student_courses_lectures
GROUP BY course_id
ORDER BY course_id;



-- Найдите все почты студентов для тех студентов, которые не зарегистрировались на самую непопулярную лекцию
SELECT email
FROM students
WHERE email NOT IN (
    SELECT student_email
    FROM student_courses_lectures
    WHERE lecture_id IN (
        SELECT lecture_id
        FROM student_courses_lectures
        GROUP BY lecture_id
        ORDER BY count(student_id), lecture_id
        LIMIT 1));
