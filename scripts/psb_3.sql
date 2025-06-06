-- Третья задача

-- Создание таблицы employee
CREATE TABLE IF NOT EXISTS employee (
  id INT,
  hire_date DATE,
  chief_id INT,
  salary INT
);

-- Заполнение данными employee
TRUNCATE TABLE employee;
INSERT INTO employee (id, hire_date, chief_id, salary) VALUES
(1, '2020-01-15', NULL, 100000.00),  -- Главный начальник (нет начальника)
(2, '2021-03-10', 1, 75000.00),  -- Подчиненный начальника 1
(3, '2019-11-01', 1, 80000.00),  -- Подчиненный начальника 1, принят раньше
(4, '2021-02-20', 2, 60000.00),  -- Подчиненный начальника 2 и 3
(4, '2022-05-20', 3, 60000.00),  
(5, '2023-01-05', 2, 65000.00),  -- Подчиненный начальника 2
(6, '2021-12-15', 3, 55000.00),  -- Подчиненный начальника 3
(7, '2022-08-01', 3, 50000.00),  -- Подчиненный начальника 3
(8, '2020-02-28', 1, 70000.00),  -- Подчиненный начальника 1
(9, '2023-05-10', 8, 45000.00),  -- Подчиненный начальника 8
(10, '2021-09-20', 8, 52000.00), -- Подчиненный начальника 8
(11, '2020-11-11', 2, 68000.00), -- Подчиненный начальника 2, принят раньше начальника
(12, '2020-01-15', NULL, 120000.00),  -- Другой главный начальник (нет начальника)
(13, '2020-01-15', 5, 150000.00),    -- Подчиненный начальника 4 и 5, принят раньше
(13, '2020-01-15', 4, 150000.00);   


-- Необходимо:
/*
1. Посчитать количество сотрудников, которые работают в компании дольше, чем их
непосредственные начальники;
*/
WITH employees_with_later_hired_chiefs AS(
SELECT e.id AS employee_id 
FROM employee e
JOIN employee chief ON e.chief_id = chief.id
GROUP BY e.id
HAVING MIN(chief.hire_date - e.hire_date) > 0) -- Считал, что у одного
                                               -- сотрудника может быть несколько начальников

SELECT COUNT(employee_id)
FROM employees_with_later_hired_chiefs;


/*
2. Проверить, есть ли дублирующиеся строки по сотруднику (id) в таблице employee –
вывести пример такого сотрудника.
*/
WITH duplicates AS(
SELECT id,
	   row_number() OVER (PARTITION BY id ORDER BY id) AS rn
FROM employee
)
SELECT e.id, 
       e.hire_date,
       e.chief_id,
       e.salary
FROM employee e
JOIN duplicates d USING(id)
WHERE d.rn = 2;
