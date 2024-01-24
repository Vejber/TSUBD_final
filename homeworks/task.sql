-- Запросы
-- 1. Выведите информацию о самолетах, выполняющих транзитные рейсы.
SELECT
    Aircrafts.number AS 'Номер самолета',
    Aircrafts.brand AS 'Марка',
    Aircrafts.model AS 'Модель',
    Aircrafts.capacity AS 'Вместимость',
    Flights.flight_number AS 'Номер рейса',
    Flights.departure_time AS 'Время вылета',
    Flights.arrival_time AS 'Время прилета',
    Flights.travel_time AS 'Время в пути',
    Flights.frequency AS 'Частота рейсов'
FROM
    Aircrafts
JOIN Flights ON Flights.aircraft_id = Aircrafts.aircraft_id
WHERE
    Flights.type = 'Транзитный';


-- 2. Список самолетов, которые превысили свой ресурс
ALTER TABLE Aircrafts
ADD COLUMN max_flight_hours_before_replacement time;
UPDATE Aircrafts
SET max_flight_hours_before_replacement = CASE
    WHEN brand = 'Boeing' THEN '700:00:00'
    WHEN brand = 'Airbus' THEN '500:00:00'
    WHEN brand = 'Irkut' THEN '500:00:00'
    WHEN brand = 'Tupolev' THEN '500:00:00'
    WHEN brand = 'Antonov' THEN '400:00:00'
    WHEN brand = 'Sukhoi' THEN '400:00:00'
END
WHERE max_flight_hours_before_replacement IS NULL;

ALTER TABLE Flights
ADD COLUMN hours_executed time;
UPDATE Flights
SET hours_executed = '600:00:00'
WHERE hours_executed IS NULL;

SELECT 
    Aircrafts.aircraft_id AS 'ID самолета',
    Aircrafts.number AS 'Номер самолета',
    SUM(Flights.hours_executed) AS 'Общее количество летных часов',
    Aircrafts.max_flight_hours_before_replacement AS 'Максимальное количество летных часов до замены'
FROM 
    Aircrafts
JOIN 
    Flights ON Aircrafts.aircraft_id = Flights.aircraft_id
GROUP BY 
    Aircrafts.aircraft_id
HAVING 
    SEC_TO_TIME(SUM(TIME_TO_SEC(Flights.hours_executed))) > Aircrafts.max_flight_hours_before_replacement;

-- 3. Среднюю длительность рейсов по дням недели.

SELECT
    frequency AS 'День недели',
    SEC_TO_TIME(AVG(TIME_TO_SEC(travel_time))) AS 'Средняя длительность'
FROM
    Flights
GROUP BY
    frequency;

-- 4. Список маршрутов (аэропорт отправления — аэропорт назначения), 
-- упорядоченных по убыванию их популярности (кол-ву рейсов совершенных по данному маршруту).

SELECT
    Departure.name AS 'Аэропорт отправления',
    Arrival.name AS 'Аэропорт назначения',
    COUNT(Airports_Flights.flight_id) AS 'Количество рейсов'
FROM
    Airports_Flights
JOIN
    Airports AS Departure ON Airports_Flights.airport_departure_id = Departure.airport_id
JOIN
    Airports AS Arrival ON Airports_Flights.airport_arrival_id = Arrival.airport_id
GROUP BY
    Airports_Flights.airport_departure_id, Airports_Flights.airport_arrival_id
ORDER BY
    COUNT(Airports_Flights.flight_id) DESC;


-- 5. Самые популярные направления из каждого аэропорта.

SELECT 
    Arrival.name AS `Аэропорт назначения`,
    Departure.name AS `Аэропорт отправления`,
    COUNT(Airports_Flights.flight_id) AS `Количество рейсов`
FROM 
    Airports_Flights
JOIN 
    Airports AS Departure ON Airports_Flights.airport_departure_id = Departure.airport_id
JOIN 
    Airports AS Arrival ON Airports_Flights.airport_arrival_id = Arrival.airport_id
GROUP BY 
    Arrival.name, Departure.name
ORDER BY 
    Arrival.name, `Количество рейсов` DESC;

-- Функции/процедуры
-- 1. Напишите процедуру по добавлению нового рейса. Если какая-то из характеристик рейса не указана, то необходимо выводить ошибку, не добавляя рейс.

DELIMITER //

CREATE PROCEDURE AddFlight(
    IN p_airline_id INT,
    IN p_aircraft_id INT,
    IN p_flight_number VARCHAR(50),
    IN p_type VARCHAR(50),
    IN p_rangee INT,
    IN p_departure_time TIME,
    IN p_arrival_time TIME,
    IN p_travel_time TIME,
    IN p_frequency VARCHAR(100),
    IN p_hours_executed TIME
)
BEGIN
    -- Проверка, что все параметры были предоставлены
    IF p_airline_id IS NULL OR
       p_aircraft_id IS NULL OR
       p_flight_number IS NULL OR
       p_type IS NULL OR
       p_rangee IS NULL OR
       p_departure_time IS NULL OR
       p_arrival_time IS NULL OR
       p_travel_time IS NULL OR
       p_frequency IS NULL OR
       p_hours_executed IS NULL THEN
       
       -- Генерация ошибки, так как MySQL не имеет встроенной поддержки выброса пользовательских исключений
       CALL raise_error('Все характеристики рейса должны быть указаны');
       
    ELSE
       -- Вставка нового рейса в таблицу Flights
       INSERT INTO Flights (airline_id, aircraft_id, flight_number, type, rangee, departure_time, arrival_time, travel_time, frequency, hours_executed)
       VALUES (p_airline_id, p_aircraft_id, p_flight_number, p_type, p_rangee, p_departure_time, p_arrival_time, p_travel_time, p_frequency, p_hours_executed);
    END IF;
END//

DELIMITER ;

CALL AddFlight(1, 10, 'SU100', 'Терминальный', 5000, '10:00:00', '15:00:00', '05:00:00', 'Ежедневно', '02:00:00');
CALL AddFlight(1, 10, 'SU100', NULL , 5000, '10:00:00', '15:00:00', '05:00:00', 'Ежедневно', '02:00:00');

-- 2. Напишите функцию, выводящую список свободных в ближайшие сутки самолетов, находящихся в определенном аэропорту.  Входные данные: id аэропорта.

DELIMITER //

CREATE FUNCTION AvailableAircrafts(p_airport_id INT) 
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
    DECLARE aircraft_list VARCHAR(1000) DEFAULT '';
    
    -- Извлечение списка самолетов, которые не участвуют в рейсах из заданного аэропорта в ближайшие сутки
    SELECT GROUP_CONCAT(DISTINCT Flights.aircraft_id SEPARATOR ', ') 
    INTO aircraft_list
    FROM Flights
    JOIN Airports_Flights ON Flights.flight_id = Airports_Flights.flight_id
    WHERE Airports_Flights.airport_departure_id = p_airport_id
    AND Flights.departure_time NOT BETWEEN NOW() AND NOW() + INTERVAL 1 DAY;

    -- Возврат списка свободных самолетов
    RETURN aircraft_list;
END//

DELIMITER ;

SELECT AvailableAircrafts(1);

