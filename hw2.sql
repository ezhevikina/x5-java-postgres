-- Создать супер-пользователя пользователя `catperson`
CREATE USER catperson SUPERUSER;

-- Создать базу данных `catproject` с правильными настройками
CREATE DATABASE catproject
ENCODING 'UTF8'
LC_COLLATE = 'en_US.UTF-8'
LC_CTYPE = 'en_US.UTF-8'
TEMPLATE template0;

-- Сделать `catperson` владельцем базы `catproject`
ALTER DATABASE catproject OWNER TO catperson;

-- Выбрать самые подходящие типы полей для хранения информации и создать таблицу `cats`
CREATE TABLE cats (
    "id" SERIAL PRIMARY KEY,
    "name" varchar(126) NOT NULL,
    "birthday" date NOT NULL,
    "gender" char(1) NOT NULL CONSTRAINT gender_m_or_f CHECK (gender = 'm' OR gender = 'f'),
    "photo" text  DEFAULT NULL,
    "description" varchar(255) DEFAULT NULL,
    "owner phone" varchar(126) DEFAULT NULL
);

-- Сделать `INSERT` сразу всех 10 котов в базу
INSERT INTO cats ("name", "birthday", "gender", "photo", "description", "owner phone")
VALUES
    ('кот 1', '2013-06-01', 'm', 'https://s1.stc.all.kpcdn.net/putevoditel/projectid_103889/images/tild3266-6236-4266-b833-393539393436__cat-3601092_1280.jpg', 'нормальный кот', '+7(499)123-45-67 доб. 4567'),
    ('кот 2', '2007-06-01', 'm', NULL, 'старый кот', '89567269911'),
    ('кот 3', '2005-06-01', 'm', NULL, 'очень старый кот', '89567269911'),
    ('кот 4', '2005-06-01', 'm', 'https://static.mk.ru/upload/objects/articles/detailPicture/d8/80/14/4b3296971_7019686.jpg', 'древний кот', '89567269911'),
    ('кот 5', '2020-06-01', 'm', NULL, 'котенок', '89070003452'),
    ('кот 6', '2020-12-31', 'm', NULL, 'проектируемый кот', '89567269911'),
    ('кот 7', '2013-06-01', 'm', 'https://cdn2.img.sputnik-ossetia.ru/images/958/50/9585051.jpg', 'брат нормального кота', '89598889066'),
    ('кот 8', '2013-06-01', 'f', NULL, 'сестра нормального кота', '89598889066'),
    ('кот 9', '2013-06-01', 'f', NULL, 'мать нормального кота', '89887560381, 80867756565'),
    ('кот 10', '2018-08-08', 'f', NULL, 'кошка', '89598889061');

-- Выбрать всех котов-мальчиков из таблицы, затем выбрать всех кошек-девочек из таблицы
SELECT * FROM cats WHERE gender = 'm';
SELECT * FROM cats WHERE gender = 'f';

-- Выбрать всех котов, у которых фото в формате `jpg` или `jpeg`
SELECT * FROM cats WHERE photo SIMILAR TO '%.jpg|%.jpeg';

-- Обновить данные для `id=4`, поставить другую дату рождения - там была ошибка
UPDATE cats SET birthday = '2005-01-01' where id = 4;

-- Удалить из базы нашего дома кота с номером `id=5` - он переехал в другой дом
DELETE FROM cats WHERE id = 5;

-- Добавить нового кота, который въезжает к нам в дом
INSERT INTO cats ("name", "birthday", "gender", "photo", "description")
VALUES
    ('кот 11', '2007-03-21', 'm', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Hermitage_cat.jpeg/1200px-Hermitage_cat.jpeg', 'новый кот');

-- Добавить новую колонку в базу: "чип: номер (цифры + буквы), может не быть", коты в базе данных должны получить какое-то значение по-умолчанию
ALTER TABLE cats ADD COLUMN "chip" varchar(126) DEFAULT NULL;

-- Обновить котов `id=3` и `id=2`, у них есть чипы - внесите их номера в таблицу
UPDATE cats SET chip = 'ab123' where id = 2;
UPDATE cats SET chip = 'ac123' where id = 3;