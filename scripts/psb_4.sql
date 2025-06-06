-- Четвертая задача

-- Создание таблицы transactions
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    client_id INTEGER NOT NULL,
    currency VARCHAR(5) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    CHECK (currency IN ('EURO', 'USD', 'RUB'))
);

-- Создание таблицы currency
CREATE TABLE IF NOT EXISTS currency (
    id SERIAL PRIMARY KEY,
    currency_date DATE NOT NULL,
    currency VARCHAR(5) NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    CHECK (currency IN ('EURO', 'USD'))
);

-- Заполнение данными transactions
TRUNCATE TABLE transactions;
INSERT INTO transactions (transaction_date, client_id, currency, amount) VALUES
-- Май 2022
('2022-05-20', 1, 'EURO', 100.00),   -- Пятница (есть курс)
('2022-05-21', 1, 'USD', 200.00),    -- Суббота (курс с пятницы 2022-05-20)
('2022-05-22', 1, 'RUB', 5000.00),   -- Воскресенье (не нужен курс)
('2022-05-23', 2, 'EURO', 259.00),   -- Понедельник (есть курс)
('2022-05-24', 2, 'USD', 300.00),    -- Вторник (есть курс)
('2022-05-24', 2, 'RUB', 5000.00),   -- Вторник (не нужен курс)
('2022-05-28', 3, 'EURO', 150.00),   -- Суббота (курс с пятницы 2022-05-27)
('2022-05-29', 3, 'USD', 250.00),    -- Воскресенье (курс с пятницы 2022-05-27)
('2022-05-30', 3, 'EURO', 350.00),   -- Праздник (курс с пятницы 2022-05-27)
('2022-05-31', 4, 'USD', 400.00),    -- Вторник (есть курс)
-- Июнь 2022
('2022-06-02', 5, 'EURO', 180.00),   -- Четверг (курс со среды 2022-06-01)
('2022-06-04', 6, 'USD', 220.00),    -- Суббота (курс с пятницы 2022-06-03)
('2022-06-05', 7, 'RUB', 7000.00);   -- Воскресенье (не нужен курс)

-- Заполнение данными currency

TRUNCATE TABLE currency;
INSERT INTO currency (currency_date, currency, value) VALUES 
-- Рабочие дни мая 2022
('2022-05-20', 'EURO', 68.5),  -- Пятница
('2022-05-20', 'USD', 59.8),
('2022-05-23', 'EURO', 69.0),  -- Понедельник
('2022-05-23', 'USD', 60.0),
('2022-05-24', 'EURO', 70.0),  -- Вторник
('2022-05-24', 'USD', 59.5),
('2022-05-27', 'EURO', 71.0),  -- Пятница
('2022-05-27', 'USD', 58.9),
-- Пропускаем выходные (28-29 мая) и праздники (30 мая - нет курса)
('2022-05-31', 'EURO', 72.0),  -- Вторник
('2022-05-31', 'USD', 58.5),
-- Июнь 2022 с пропущенными датами
('2022-06-01', 'EURO', 71.5),
('2022-06-01', 'USD', 58.0),
('2022-06-03', 'EURO', 71.0),
('2022-06-03', 'USD', 57.8);


/*
1. Вычислить стоимость всех покупок для каждого клиента, результат посчитать в рублях;
*/

SELECT t.client_id,
       SUM( CASE
       		WHEN t.currency IN ('USD', 'EURO') THEN t.amount * c.value
       		ELSE t.amount
       		END) AS total_amount 
FROM transactions t
LEFT JOIN currency c ON c.currency_date = t.transaction_date 
                    AND c.currency = t.currency
GROUP BY t.client_id
ORDER BY t.client_id;

/*
2. Вычислить стоимость всех покупок в рублях для каждого клиента в ситуации, когда курс
ЦБ есть не на все даты (в таблице валют отсутствует строка с датой). На праздники и
выходные устанавливается курс ЦБ в крайний рабочий день перед ними.
*/

WITH closest_rates AS(
SELECT t.client_id,
       t.amount,
       c.value,
       ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY c.currency_date DESC) AS rn
FROM transactions t 
LEFT JOIN currency c ON c.currency_date <= t.transaction_date
                     AND c.currency = t.currency
)

SELECT client_id,
       SUM( CASE
       		WHEN value IS NULL THEN amount * 1
       		ELSE amount * value
       		END
       		) AS total_amount 
FROM closest_rates
WHERE rn = 1
GROUP BY client_id;
