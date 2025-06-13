-- Devuelve el valor máximo
SELECT MAX(account_id) FROM account;

-- Devuelve el valor máximo y la declaración contenedora devuelve datos sobre esa cuenta.
SELECT account_id, product_cd, cust_id, avail_balance FROM account
WHERE account_id = (SELECT MAX(account_id) FROM account);


-- Datos sobre todas las cuentas que no fueron abiertas por el cajero principal en una sucursal.
SELECT account_id, product_cd, cust_id, avail_balance FROM account
WHERE open_emp_id <> (SELECT e.emp_id
FROM employee e INNER JOIN branch b
ON e.assigned_branch_id = b.branch_id
WHERE e.title = 'Head Teller' AND b.city = 'Woburn');

SELECT account_id, product_cd, cust_id, avail_balance FROM account
WHERE open_emp_id <> (SELECT e.emp_id
FROM employee e INNER JOIN branch b
ON e.assigned_branch_id = b.branch_id
WHERE e.title = 'Teller' AND b.city = 'Woburn');


SELECT e.emp_id FROM employee e INNER JOIN branch b ON e.assigned_branch_id = b.branch_id 
WHERE e.title = 'Teller' AND b.city = 'Woburn';


-- IN  --
SELECT branch_id, name, city FROM branch WHERE name IN ('Headquarters', 'Quincy Branch');
SELECT branch_id, name, city FROM branch WHERE name = 'Headquarters' OR name = 'Quincy Branch';

-- Los empleados que supervisan a otros empleados
SELECT emp_id, fname, lname, title FROM employee
WHERE emp_id IN (SELECT superior_emp_id FROM employee);


-- NOT -- 
SELECT superior_emp_id FROM employee;

-- Los empleados que no supervisan a otros empleados.
SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id NOT IN (SELECT superior_emp_id
FROM employee
WHERE superior_emp_id IS NOT NULL);


-- ALL --
-- Todos los empleados cuyos ID no sea igual a ninguno de los ID de supervisor.
SELECT emp_id, fname, lname, title
FROM employee
WHERE emp_id <> ALL (SELECT superior_emp_id
FROM employee
WHERE superior_emp_id IS NOT NULL);

-- Todas la cuentas que tengan un saldo disponible menor que todas las cuentas de una persona.
SELECT account_id, cust_id, product_cd, avail_balance FROM account
WHERE avail_balance < ALL (SELECT a.avail_balance
FROM account a INNER JOIN individual i ON a.cust_id = i.cust_id
WHERE i.fname = 'Frank' AND i.lname = 'Tucker');

-- ANY --
-- Todas las cuentas que tengan un saldo disponible mayor que cualquiera de las cuentas de una persona:
SELECT account_id, cust_id, product_cd, avail_balance FROM account
WHERE avail_balance > ANY (SELECT a.avail_balance
FROM account a INNER JOIN individual i ON a.cust_id = i.cust_id
WHERE i.fname = 'Frank' AND i.lname = 'Tucker');


-- Multicolumn: Múltiples subconsultas de una sola columna --
-- Dos subconsultas para identificar el ID de una sucursal y los ID de empleados
-- La consulta contenedora utiliza esta información
-- Para mostrar todas las cuentas corrientes abiertas por un cajero en una sucursal.
SELECT account_id, product_cd, cust_id FROM account
WHERE open_branch_id = (SELECT branch_id
FROM branch
WHERE name = 'Woburn Branch')
AND open_emp_id IN (SELECT emp_id
FROM employee
WHERE title = 'Teller' OR title = 'Head Teller');


SELECT account_id, product_cd, cust_id FROM account
WHERE (open_branch_id, open_emp_id) IN
(SELECT b.branch_id, e.emp_id
FROM branch b INNER JOIN employee e
ON b.branch_id = e.assigned_branch_id WHERE b.name = 'Woburn Branch'
AND (e.title = 'Teller' OR e.title = 'Head Teller'));


-- Correlacionas --
-- Cuenta la cantidad de cuentas de cada cliente, y la consulta contenedora recupera aquellos clientes que tienen exactamente dos cuentas:
SELECT c.cust_id, c.cust_type_cd, c.city FROM customer c
WHERE 2 = (SELECT COUNT(*)
FROM account a
WHERE a.cust_id = c.cust_id);

-- La subconsulta correlacionada se ejecuta 13 veces (una vez por cada fila de cliente) y cada ejecución de la subconsulta devuelve el saldo total de la cuenta del cliente dado.
SELECT c.cust_id, c.cust_type_cd, c.city FROM customer c
WHERE (SELECT SUM(a.avail_balance)
FROM account a
WHERE a.cust_id = c.cust_id) BETWEEN 5000 AND 10000;


