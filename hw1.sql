-- Вывести общее количество результатов
SELECT COUNT(*) FROM exam_results;

-- Найти средний показатель финального результата для всех участников
SELECT AVG(result) FROM exam_results;

-- Найти минимальный и максимальный показатель.
SELECT MAX(result), MIN(result) FROM exam_results;

-- Вывести всю информацию о участниках, которые набрали соответсвующие максимальный или минимальный балл
SELECT * FROM exam_results
WHERE result IN (
(SELECT MAX(result) FROM exam_results),
(SELECT MIN(result) FROM exam_results));

-- Найти средний показатель финального результата для граждан РФ и для неграждан.
-- Должно получиться: is_citizen, среднее
SELECT is_citizen, AVG(result)
FROM exam_results
GROUP BY is_citizen;

-- Найти минимальный, средний и максимальный показатель для каждого года рождения.
-- В итоге должно получиться: год рождения, минимальный, средний, масимальный
SELECT EXTRACT(year FROM birthday) AS year, MIN(result), MAX(result), AVG(result)
FROM exam_results
GROUP BY year
ORDER BY year;

-- Найти результаты для всех людей, которых зовут Олег или их полное имя длиннее 20 символов,
-- отсортировав по возврасту: самые молодые вверху
SELECT result FROM exam_results
WHERE fullname LIKE 'Олег %'
OR LENGTH(fullname) > 20
ORDER BY birthday DESC;

-- Показать полную информацию о людях, чей результат выше среднего
SELECT * FROM exam_results
WHERE result > (SELECT AVG(result) FROM exam_results);

-- Показать полную информацию о 3 людях с высшими результатами
SELECT * FROM exam_results
ORDER BY result DESC
LIMIT 3;