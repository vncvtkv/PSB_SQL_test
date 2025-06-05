-- Четвертая задача

-- Создание таблицы transactions
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    client_id INTEGER NOT NULL,
    currency VARCHAR(3) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL
);

-- Создание таблицы currency
CREATE TABLE currency (
    id SERIAL PRIMARY KEY,
    currency_date DATE NOT NULL,
    currency VARCHAR(10) NOT NULL,
    value DECIMAL(15, 2) NOT NULL
);