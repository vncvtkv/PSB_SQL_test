-- Вторая задача

-- Создание таблицы credit
CREATE TABLE IF NOT EXISTS credit (
credit_id INT PRIMARY KEY,
issued_date DATE NOT NULL
);

-- Создание таблицы credit_calculations
CREATE TABLE IF NOT EXISTS credit_calculations (
credit_id INT,
calculation_date DATE NOT NULL,
status VARCHAR(10),
FOREIGN KEY (credit_id) REFERENCES credit (credit_id) ON
DELETE
	CASCADE,
	CHECK (status IN ('ACTIVE', 'EXPIRED', 'COMPLETED'))
);

-- Заполнение данными credit
TRUNCATE TABLE credit CASCADE;
INSERT INTO credit (credit_id, issued_date) VALUES 
(1, '2024-12-31'),
(2, '2024-12-30'),
(3, '2024-12-30'),
(4, '2025-04-05'),
(5, '2025-05-12'),
(6, '2025-07-12');

-- Заполнение данными credit_calculations
TRUNCATE TABLE credit_calculations;
INSERT INTO credit_calculations (credit_id, calculation_date, status) VALUES 
(1, '2024-12-31', 'ACTIVE'),    --ACTIVE - активный
(1, '2025-01-01', 'ACTIVE'),    --EXPIRED - просрочка
(1, '2025-01-02', 'ACTIVE'),    --COMPLETED - закрытый
(1, '2025-01-03', 'ACTIVE'),

(2, '2024-12-30', 'ACTIVE'),
(2, '2024-12-31', 'ACTIVE'),
(2, '2025-01-01', 'EXPIRED'),
(2, '2025-01-02', 'EXPIRED'),

(3, '2024-12-30', 'ACTIVE'),
(3, '2024-12-31', 'ACTIVE'),
(3, '2025-01-01', 'COMPLETED'),

(4, '2025-04-05', 'ACTIVE'),
(4, '2025-04-06', 'ACTIVE'),
(4, '2025-04-07', 'EXPIRED'),
(4, '2025-04-08', 'ACTIVE'),
(4, '2025-04-09', 'COMPLETED'),

(5, '2025-05-12', 'ACTIVE'),
(5, '2025-05-13', 'ACTIVE'),

(6, '2025-07-12', 'ACTIVE'),
(6, '2025-07-13', 'EXPIRED'),
(6, '2025-07-14', 'EXPIRED'),
(6, '2025-07-15', 'EXPIRED'),
(6, '2025-07-16', 'EXPIRED');


-- Необходимо:
/*
1. Для каждого кредита, выданного в этом году, вывести количество дней, когда он
находился в просрочке (если кредит не имел просрочки, то по таким кредитам выводить
значение 0);
*/

SELECT c.credit_id,
	   COUNT(CASE WHEN cc.status = 'EXPIRED' THEN 1 END) AS days_in_expired_status
FROM credit c
JOIN credit_calculations cc USING(credit_id)
WHERE date_part('year', c.issued_date) = date_part('year', current_date)
GROUP BY c.credit_id;


/*
2. Для каждого кредита вывести актуальный статус (с максимальной датой calculation_date).
Написать 2 варианта решения – с использованием оконной функции и без неё;
*/

-- а) без оконной функции
WITH max_calc_date AS (
SELECT c.credit_id,
	   MAX(calculation_date) AS max_date
FROM credit c
JOIN credit_calculations cc USING(credit_id)
GROUP BY c.credit_id)

SELECT credit_id,
	   status
FROM credit_calculations
WHERE (credit_id, calculation_date) IN (SELECT * FROM max_calc_date);

-- б) с оконной функцией
SELECT DISTINCT
    credit_id,
    LAST_VALUE(status) OVER (
        PARTITION BY credit_id 
        ORDER BY calculation_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as final_status
FROM credit_calculations
ORDER BY credit_id;

/*
3. После update таблицы credit_calculations , поля
credit_id и calculation_date остались корректными, а поле status стало частично (null). 
Требуется написать запрос, показывающий количество кредитов, по которым стали
пустыми все статусы - вывести количество таких кредитов.
*/

-- Гипотетический update, занулит все статусы у 4 и 5  credit_id
UPDATE credit_calculations
SET status = NULL
WHERE calculation_date BETWEEN '2025-01-01' AND '2025-06-30';


-- Запрос
SELECT COUNT(DISTINCT cc1.credit_id) AS credit_null_status
FROM credit_calculations cc1
WHERE NOT EXISTS (
    SELECT 1 
    FROM credit_calculations cc2
    WHERE cc2.credit_id = cc1.credit_id
    AND cc2.status IS NOT NULL
);


