-- Вторая задача

-- Создание таблицы credit
create table if not exists credit (
credit_id INT primary key,
issued_date DATE not null
);

-- Создание таблицы credit_calculations
create table if not exists credit_calculations (
credit_id INT,
calculation_date DATE not null,
status VARCHAR(10),
FOREIGN KEY (credit_id) REFERENCES credit (credit_id) ON DELETE cascade,
CHECK (status IN ('ACTIVE', 'EXPIRED', 'COMPLETED'))
);

-- Заполнение данными credit
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM credit) THEN
    INSERT INTO credit (credit_id, issued_date) VALUES 
(1, '2024-12-31'),
(2, '2024-12-30'),
(3, '2024-12-30'),
(4, '2025-04-05'),
(5, '2025-05-12'),
(6, '2025-07-12');

  END IF;
END $$;

-- Заполнение данными credit_calculations
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM credit_calculations) THEN
    INSERT INTO credit_calculations (credit_id, calculation_date, status) VALUES 
(1, '2024-12-31', 'ACTIVE'),
(1, '2025-01-01', 'ACTIVE'),
(1, '2025-01-02', 'ACTIVE'),
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
c
(5, '2025-05-12', 'ACTIVE'),
(5, '2025-05-13', 'ACTIVE'),

(6, '2025-07-12', 'ACTIVE'),
(6, '2025-07-13', 'EXPIRED'),
(6, '2025-07-14', 'EXPIRED'),
(6, '2025-07-15', 'EXPIRED'),
(6, '2025-07-16', 'EXPIRED');
  END IF;
END $$;

-- Необходимо::
-- Первый пункт
/*
Для каждого кредита, выданного в этом году, вывести количество дней, когда он
находился в просрочке (если кредит не имел просрочки, то по таким кредитам выводить
значение 0)
*/

select c.credit_id,
       COUNT(CASE WHEN cc.status = 'EXPIRED' THEN 1 END) AS days_in_expired_status
from credit c 
join credit_calculations cc using(credit_id)
where date_part('year', c.issued_date) = date_part('year', current_date)
group by c.credit_id;

-- Второй пункт
/*
Для каждого кредита вывести актуальный статус (с максимальной датой calculation_date).
Здесь хотелось бы увидеть 2 варианта решения – с использованием оконной функции и
без неё,
*/

-- а) без оконной функции
with max_calc_date as (
select c.credit_id,
       MAX(calculation_date) as max_date
from credit c 
join credit_calculations cc using(credit_id)
group by c.credit_id)

select credit_id,
       status
from credit_calculations
where (credit_id, calculation_date) in (select * from max_calc_date)



-- б) с оконной функцией
