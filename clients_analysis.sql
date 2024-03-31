/*
	Ogni indicatore va riferito al singolo per id_cliente
    
	Età per id_cliente
	Numero di transazioni in uscita su tutti i conti per id_cliente
	Numero di transazioni in entrata su tutti i conti per id_cliente
	Importo transato in uscita su tutti i conti per id_cliente
	Importo transato in entrata su tutti i conti per id_cliente
	Numero totale di conti posseduti per id_cliente
	Numero di conti posseduti per tipologia (un indicatore per tipo) per id_cliente
    Numero di transazioni in uscita per tipologia (un indicatore per tipo) per id_cliente
	Numero di transazioni in entrata per tipologia (un indicatore per tipo) per id_cliente    
	Importo transato in uscita per tipologia di conto (un indicatore per tipo) per id_cliente
	Importo transato in entrata per tipologia di conto (un indicatore per tipo) per id_cliente
*/

-- Esplorazione database
SELECT * FROM banca.cliente ORDER BY id_cliente;
SELECT * FROM banca.conto ORDER BY 2;
SELECT * FROM banca.tipo_conto;
SELECT * FROM banca.tipo_transazione;
SELECT * FROM banca.transazioni ORDER BY 1;

-- Età
CREATE TEMPORARY TABLE eta AS
SELECT
	cliente.id_cliente,
	timestampdiff(year, cliente.data_nascita, CURRENT_DATE()) AS eta
FROM banca.cliente cliente
ORDER BY id_cliente ASC;
SELECT * FROM eta;

-- Numero di transazioni in uscita su tutti i conti per id_cliente
CREATE TEMPORARY TABLE out_trans AS
SELECT
	trans.id_conto,
	COUNT(trans.data) AS out_trans
FROM banca.transazioni trans
INNER JOIN banca.tipo_transazione tipo
ON trans.id_tipo_trans = tipo.id_tipo_transazione AND tipo.segno = '-'
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE out_id_cliente AS
SELECT conto.id_cliente, SUM(trans.out_trans) AS out_trans
FROM out_trans trans
INNER JOIN banca.conto conto
ON trans.id_conto = conto.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM out_id_cliente;

-- Numero di transazioni in entrata su tutti i conti per id_cliente
CREATE TEMPORARY TABLE in_trans AS
SELECT
	trans.id_conto,
	COUNT(trans.data) AS in_trans
FROM banca.transazioni trans
INNER JOIN banca.tipo_transazione tipo
ON trans.id_tipo_trans = tipo.id_tipo_transazione AND tipo.segno = '+'
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE in_id_cliente AS
SELECT conto.id_cliente, SUM(trans.in_trans) AS in_trans
FROM in_trans trans
INNER JOIN banca.conto conto
ON trans.id_conto = conto.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM in_id_cliente;

-- 	Importo transato in entrata su tutti i conti per id_cliente
CREATE TEMPORARY TABLE outcome_tot AS
SELECT id_conto, SUM(importo) AS tot
FROM banca.transazioni
where importo<0
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE outcome_tot_id AS
SELECT
	conti.id_cliente,ROUND(SUM(outcome.tot), 2) AS tot_outcome
FROM outcome_tot outcome
INNER JOIN banca.conto conti
ON outcome.id_conto = conti.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM outcome_tot_id;

-- 	Importo transato in entrata su tutti i conti per id_cliente
CREATE TEMPORARY TABLE income_tot AS
SELECT id_conto, SUM(importo) AS tot
FROM banca.transazioni
where importo>0
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE income_tot_id AS
SELECT
	conti.id_cliente, ROUND(SUM(income.tot), 2) AS tot_income
FROM income_tot income
INNER JOIN banca.conto conti
ON income.id_conto = conti.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM income_tot_id;

-- Numero totale di conti posseduti
CREATE TEMPORARY TABLE tot_account AS
SELECT
	conti.id_cliente,
    COUNT(conti.id_conto) AS num_conti
FROM banca.conto conti
GROUP BY 1
ORDER BY 1;
SELECT * FROM tot_account;

-- 	Numero di conti posseduti per tipologia (un indicatore per tipo) per id_cliente
CREATE TEMPORARY TABLE account_id as
SELECT
	id_cliente,
    SUM(CASE WHEN id_tipo_conto = 0 THEN 1 ELSE 0 END) as count_base,
    SUM(CASE WHEN id_tipo_conto = 1 THEN 1 ELSE 0 END) as count_business,
    SUM(CASE WHEN id_tipo_conto = 2 THEN 1 ELSE 0 END) as count_privati,
    SUM(CASE WHEN id_tipo_conto = 3 THEN 1 ELSE 0 END) as count_famiglie
FROM banca.conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM account_id;


-- Numero di transazioni in uscita per tipologia per conto (un indicatore per tipo)
CREATE TEMPORARY TABLE outcome_count_type AS
SELECT trans.id_conto,
	SUM(CASE WHEN trans.id_tipo_trans = 3 THEN 1 END) AS amazon,
	SUM(CASE WHEN trans.id_tipo_trans = 4 THEN 1 END) AS mutuo,
	SUM(CASE WHEN trans.id_tipo_trans = 5 THEN 1 END) AS hotel,
	SUM(CASE WHEN trans.id_tipo_trans = 6 THEN 1 END) AS aereo,
	SUM(CASE WHEN trans.id_tipo_trans = 7 THEN 1 END) AS supermercato
FROM banca.transazioni trans
INNER JOIN banca.tipo_transazione tipo_trans
ON trans.id_tipo_trans = tipo_trans.id_tipo_transazione AND tipo_trans.segno = '-'
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE outcome_count_type_id AS
SELECT
	conti.id_cliente,
    SUM(outcome.amazon) AS count_amazon,
    SUM(outcome.mutuo) AS count_mutuo,
    SUM(outcome.hotel) AS count_hotel,
    SUM(outcome.aereo) AS count_aereo,
    SUM(outcome.supermercato) AS count_supermercato
FROM outcome_count_type outcome
INNER JOIN banca.conto conti
ON outcome.id_conto = conti.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM outcome_count_type_id;

-- Numero di transazioni in entrata per tipologia per conto (un indicatore per tipo)
CREATE TEMPORARY TABLE income_count_type AS
SELECT trans.id_conto,
	SUM(CASE WHEN trans.id_tipo_trans = 0 THEN 1 ELSE 0 END) AS stipendio,
	SUM(CASE WHEN trans.id_tipo_trans = 1 THEN 1 ELSE 0 END) AS pensione,
	SUM(CASE WHEN trans.id_tipo_trans = 2 THEN 1 ELSE 0 END) AS dividendi
FROM banca.transazioni trans
INNER JOIN banca.tipo_transazione tipo_trans
ON trans.id_tipo_trans = tipo_trans.id_tipo_transazione AND tipo_trans.segno = '+'
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE income_count_type_id AS
SELECT
	conti.id_cliente,
    SUM(income.stipendio) AS count_stipendio,
    SUM(income.pensione) AS count_pensione,
    SUM(income.dividendi) AS count_dividendi
FROM income_count_type income
INNER JOIN banca.conto conti
ON income.id_conto = conti.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM income_count_type_id;

-- Importo transato in uscita per tipologia di conto (un indicatore per tipo) per id_cliente
CREATE TEMPORARY TABLE account_out_transaction AS 
SELECT id_conto, SUM(importo) AS importo
FROM banca.transazioni trans
where trans.id_tipo_trans in(3,4,5,6,7)
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE outcome_type_id AS
SELECT 
    conto.id_cliente,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 0 THEN trans.importo ELSE 0 END), 2) AS outcome_base,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 1 THEN trans.importo ELSE 0 END), 2) AS outcome_business,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 2 THEN trans.importo ELSE 0 END), 2) AS outcome_privati,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 3 THEN trans.importo ELSE 0 END), 2) AS outcome_famiglie    
FROM account_out_transaction trans
INNER JOIN banca.conto conto
ON trans.id_conto = conto.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM outcome_type_id;

-- Importo transato in entrata per tipologia di conto (un indicatore per tipo) per id_cliente
CREATE TEMPORARY TABLE account_in_transaction AS 
SELECT id_conto, SUM(importo) AS importo
FROM banca.transazioni trans
where trans.id_tipo_trans in(0,1,2)
GROUP BY 1
ORDER BY 1;

CREATE TEMPORARY TABLE income_type_id AS
SELECT 
    conto.id_cliente,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 0 THEN trans.importo ELSE 0 END), 2) AS income_base,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 1 THEN trans.importo ELSE 0 END), 2) AS income_business,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 2 THEN trans.importo ELSE 0 END), 2) AS income_privati,
    ROUND(SUM(CASE WHEN conto.id_tipo_conto = 3 THEN trans.importo ELSE 0 END), 2) AS income_famiglie    
FROM account_in_transaction trans
INNER JOIN banca.conto conto
ON trans.id_conto = conto.id_conto
GROUP BY 1
ORDER BY 1;
SELECT * FROM income_type_id;

-- Tabella complessiva che mostra tutte le metriche per id_cliente
CREATE TEMPORARY TABLE summary AS
SELECT
	clienti.id_cliente,
    eta.eta,
    out_id_cliente.out_trans,
    in_id_cliente.in_trans,
    outcome_tot_id.tot_outcome,
    income_tot_id.tot_income,
    tot_account.num_conti,
    account_id.count_base,
    account_id.count_business,
    account_id.count_privati,
    account_id.count_famiglie,
    outcome_id.count_amazon,
    outcome_id.count_mutuo,
    outcome_id.count_hotel,
    outcome_id.count_aereo,
    outcome_id.count_supermercato,
    income_id.count_stipendio,
    income_id.count_pensione,
    income_id.count_dividendi,
    outcome_type.outcome_base,
    outcome_type.outcome_business,
    outcome_type.outcome_privati,
    outcome_type.outcome_famiglie,
    income_type.income_base,
    income_type.income_business,
    income_type.income_privati,
    income_type.income_famiglie
FROM banca.cliente clienti
LEFT JOIN eta ON clienti.id_cliente = eta.id_cliente
LEFT JOIN out_id_cliente ON clienti.id_cliente = out_id_cliente.id_cliente
LEFT JOIN in_id_cliente ON clienti.id_cliente = in_id_cliente.id_cliente
LEFT JOIN outcome_tot_id ON clienti.id_cliente = outcome_tot_id.id_cliente
LEFT JOIN income_tot_id ON clienti.id_cliente = income_tot_id.id_cliente
LEFT JOIN tot_account ON clienti.id_cliente = tot_account.id_cliente
LEFT JOIN account_id ON clienti.id_cliente = account_id.id_cliente
LEFT JOIN outcome_count_type_id AS outcome_id ON clienti.id_cliente = outcome_id.id_cliente
LEFT JOIN income_count_type_id AS income_id ON clienti.id_cliente = income_id.id_cliente
LEFT JOIN outcome_type_id AS outcome_type ON clienti.id_cliente = outcome_type.id_cliente
LEFT JOIN income_type_id AS income_type ON clienti.id_cliente = income_type.id_cliente;
SELECT * FROM summary;
