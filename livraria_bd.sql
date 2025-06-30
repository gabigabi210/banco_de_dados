INSERT INTO autores (nome, nacionalidade, data_nascimento) VALUES 
('Gabriel García Marquez', 'Colombiana', '1927-03-06'),
('Clarice Lispector', 'Brasileira', '1920-12-10'),
('Stephen King', 'Americana', '1947-09-21');

ALTER TABLE livros ALTER COLUMN isbn TYPE VARCHAR(17);

INSERT INTO livros (titulo, ano_publicacao, isbn, preco, autor_id) VALUES
('Dom Casmurro', 1899, '978-85-8022-019-3', 35.00, 1),
('Orgulho e Preconceito', 1813, '978-85-359-0277-7', 45.00, 2),
('Cem Anos de Solidão', 1967, '978-85-359-0279-7', 60.00, 3),
('Memórias Póstumas de Brás Cubas', 1881, '978-85-8022-020-9',40,1),
('A Hora da Estrela', 1977, '978-85-325-2732-2',30,4),
('O Iluminado',1977,'978-85-325-0551-1', 55, 5),
('Persuasão', 1811, '978-85-325-1064-5', 42.50, 2),
('Água Viva',1964, '978-85-325-1066-9', 38.00, 4);

SELECT * FROM livros;

SELECT 
	L.titulo,
	A.nome
FROM 
	livros as L 
INNER JOIN 
	autores as A on L.autor_id = A.id_autor
WHERE
	L.autor_id = 1;

SELECT 
	titulo, ano_publicacao
FROM 
	livros
WHERE
	ano_publicacao > 1950;

SELECT 
	nome, nacionalidade
FROM
	autores
WHERE
	nacionalidade = 'Brasileira';

SELECT 
	L.titulo,
	L.ano_publicacao,
	A.nome AS nome_autor
FROM
	livros AS L
INNER JOIN
	autores AS A ON L.autor_id = A.id_autor;

SELECT 
	titulo, preco
FROM
 	livros
WHERE 
	preco > 50;

SELECT 
	A.nacionalidade, SUM(L.preco * L.estoque) as soma_valor
FROM
 	autores AS A
INNER JOIN
	livros AS L ON L.autor_id = A.id_autor
GROUP BY
 	nacionalidade;

SELECT 
	A.nome AS nome_autor,
	COUNT(L.id) AS quantidade_livros
FROM
	autores AS A
INNER JOIN
	livros AS L ON A.id_autor = L.autor_id
GROUP BY
	L.autor_id, A.nome;

SELECT 
	A.nacionalidade, COUNT(L.id)
FROM
 	autores AS A
INNER JOIN
	livros AS L ON L.autor_id = A.id_autor
GROUP BY
	A.nacionalidade;

SELECT 
	A.nome
FROM
	autores AS A
INNER JOIN
	livros AS L ON L.autor_id = A.id_autor
GROUP BY 
 	A.nome
HAVING
	count(L.id) > 1;

SELECT 
	*
FROM
	autores AS A
INNER JOIN
	livros AS L ON L.autor_id = A.id_autor;

SELECT * FROM livros
WHERE preco BETWEEN 30 AND 40;

CREATE TABLE log_precos_livros (
	id SERIAL PRIMARY KEY,
	livro_id INTEGER NOT NULL,
	preco_antigo DECIMAL (10,2) NOT NULL,
	preco_novo DECIMAL (10,2) NOT NULL,
	data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	usuario_alteracao VARCHAR(100) DEFAULT CURRENT_USER
);

CREATE OR REPLACE FUNCTION registrar_alteracao_preco()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.preco <> OLD.preco THEN
		INSERT INTO log_precos_livros (livro_id, preco_antigo, preco_novo)
		VALUES (OLD.id, OLD.preco, NEW.preco);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE livros ADD COLUMN estoque INT NOT NULL DEFAULT 0;

CREATE TABLE vendas
(
	cod_venda INT,
	id_livro INT NOT NULL REFERENCES livros(id),
	quant_vendida INT
);

CREATE TRIGGER trg_atualiza_estoque_venda
AFTER INSERT ON vendas -- A trigger deve ser acionada após uma INSERÇÃO de venda
FOR EACH ROW
EXECUTE FUNCTION atualiza_estoque();

CREATE OR REPLACE FUNCTION atualiza_estoque()
RETURNS TRIGGER AS $$
BEGIN
UPDATE livros SET estoque = estoque - NEW.quant_vendida WHERE NEW.id_livro = id;
RETURN NEW;
END ;
$$ LANGUAGE plpgsql;

INSERT INTO vendas VALUES (3, 4, 4);
SELECT * FROM livros;
