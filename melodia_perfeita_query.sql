-- Ative o schema (se quiser criar um novo para este, tipo 'melodia_infinita')
-- USE melodia_infinita;

-- Tabela de Usuários
CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome_usuario VARCHAR(100) NOT NULL,
    plano VARCHAR(50) NOT NULL, -- Ex: 'Gratuito', 'Premium'
    data_registro DATE NOT NULL
);

-- Tabela de Musicas
CREATE TABLE Musicas (
    id_musica INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(150) NOT NULL,
    artista VARCHAR(100) NOT NULL,
    genero VARCHAR(50),
    duracao_segundos INT NOT NULL -- Duração da música em segundos
);

-- Tabela de Reproducoes (Histórico de plays)
CREATE TABLE Reproducoes (
    id_reproducao INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_musica INT NOT NULL,
    data_hora_reproducao DATETIME NOT NULL DEFAULT NOW(), -- Data e hora exata da reprodução
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_musica) REFERENCES Musicas(id_musica)
);

-- Inserir Usuários
INSERT INTO Usuarios (nome_usuario, plano, data_registro) VALUES
('Alice', 'Premium', '2024-01-15'),
('Bob', 'Gratuito', '2024-02-01'),
('Charlie', 'Premium', '2024-03-10'),
('Diana', 'Gratuito', '2024-04-05'),
('Eve', 'Premium', '2024-05-20');

-- Inserir Músicas
INSERT INTO Musicas (titulo, artista, genero, duracao_segundos) VALUES
('Song A', 'Artist X', 'Pop', 180),
('Song B', 'Artist Y', 'Rock', 240),
('Song C', 'Artist X', 'Pop', 200),
('Song D', 'Artist Z', 'Eletronica', 220),
('Song E', 'Artist Y', 'Rock', 300),
('Song F', 'Artist X', 'Pop', 190),
('Song G', 'Artist Z', 'Eletronica', 210);

-- Inserir Reproduções (misturando usuários e músicas)
-- Vamos assumir IDs de usuário 1-5 e IDs de música 1-7
INSERT INTO Reproducoes (id_usuario, id_musica, data_hora_reproducao) VALUES
(1, 1, '2025-06-24 10:00:00'), -- Alice ouve Song A
(1, 2, '2025-06-24 10:05:00'), -- Alice ouve Song B
(2, 1, '2025-06-24 11:00:00'), -- Bob ouve Song A
(3, 3, '2025-06-24 12:00:00'), -- Charlie ouve Song C
(1, 1, '2025-06-24 13:00:00'), -- Alice ouve Song A (de novo!)
(4, 4, '2025-06-24 14:00:00'), -- Diana ouve Song D
(5, 5, '2025-06-24 15:00:00'), -- Eve ouve Song E
(1, 6, '2025-06-24 16:00:00'), -- Alice ouve Song F
(2, 3, '2025-06-24 17:00:00'), -- Bob ouve Song C
(3, 2, '2025-06-24 18:00:00'), -- Charlie ouve Song B
(4, 5, '2025-06-24 19:00:00'), -- Diana ouve Song E
(1, 7, '2025-06-25 08:00:00'), -- Alice ouve Song G
(3, 1, '2025-06-25 09:00:00'), -- Charlie ouve Song A
(5, 7, '2025-06-25 10:00:00'); -- Eve ouve Song G
-- qual o titulo de musica e quantas vezes foi tocada
select 
	M.titulo,
    count(R.id_musica) as total_reproducoes
from
	musicas as M 
inner join
	reproducoes as R on M.id_musica = R.id_musica
group by
	M.id_musica, M.titulo
order by
	total_reproducoes desc;

-- o nome e o total de musicas que alguem reproduziu
select
	U.nome_usuario,
    count(R.id_usuario) as total_musicas
from 
	usuarios as U
inner join 
	reproducoes as R on R.id_usuario = U.id_usuario
group by
	R.id_usuario, U.nome_usuario
order by
	total_musicas desc;
    
-- para cada genero qual a duracao media das musicas
select 
	genero,
    avg(duracao_segundos) as media_genero
from 
	musicas
group by
	genero;
    
-- quantas reproducoes feitas por usuarios de cada tipo de plano
select
	U.plano,
    count(R.id_usuario) as total_reproducoes
from
	usuarios as U
inner join
	reproducoes as R on U.id_usuario = R.id_usuario
group by
	U.plano
having total_reproducoes > 5;

-- Desafio 1: Artistas Mais Populares por Gênero

--    Para cada gênero musical, mostre o artista e a contagem total de reproduções para as músicas desse artista.
--    Mostre apenas os gêneros que tiveram um total de reproduções maior que 15.
--    Ordene os resultados pelo gênero (alfabeticamente) e, dentro de cada gênero, pelo total de reproduções do artista (do maior para o menor).
-- Exemplo: Inserir mais 10 reproduções para 'Song A' (id_musica = 1)
-- Isso faria 'Artist X - Pop' ter 7 + 10 = 17 reproduções

select
	M.genero,
	M.artista,
    count(R.id_musica) as total_reproducoes
from
	musicas as M
inner join
	reproducoes as R on R.id_musica = M.id_musica
group by 
	M.genero, M.artista
having total_reproducoes > 15
order by M.genero asc, total_reproducoes desc
;

-- Desafio 2: Usuários Premium Ativos

--    Mostre o nome do usuário e a quantidade de músicas diferentes que ele ou ela reproduziu.
--    Inclua apenas usuários que têm o plano 'Premium'.
--    Mostre apenas os usuários que reproduziram mais de 3 músicas diferentes.
--    Ordene pelo nome do usuário (alfabeticamente).

select 
	U.nome_usuario,
    count(R.id_usuario) as quantidade_musicas
from 
	usuarios as U
inner join
	reproducoes as R on U.id_usuario = R.id_usuario
where 
	U.plano = 'Premium'
group by
	R.id_usuario, U.nome_usuario
having
	quantidade_musicas > 3
order by
	U.nome_usuario;

-- Desafio 3: Músicas Curtas e Longas por Artista

--    Para cada artista, mostre a duração mínima e a duração máxima de suas músicas.
--    Inclua apenas os artistas que possuem músicas com duração mínima inferior a 200 segundos.
--    Ordene pelo nome do artista.

select 
	artista,
    min(duracao_segundos) as duracao_minima,
    max(duracao_segundos) as duracao_maxima
from
	musicas
group by
	artista
having
	duracao_minima < 200
order by artista desc;

-- Desafio 4: Receita Potencial por Plano (e Vendas Recentes)

--    Suponha que cada reprodução de usuário 'Premium' gere uma receita potencial de $0.05, e cada reprodução de usuário 'Gratuito' gere $0.01.
--    Calcule o total de reproduções e a receita potencial total para cada tipo de plano (Premium, Gratuito) para reproduções que ocorreram APENAS no mês de Junho de 2025.
--    Mostre apenas os planos cuja receita potencial total seja maior que $1.00.
--    Ordene pelo tipo de plano.

select
	U.plano,
	count(R.id_reproducao) as total_reproducoes,
    sum(
		case
			when U.plano = 'Premium' then 0.05
			when U.plano = 'Gratuito' then 0.01
		end
	) as receita_potencial_total
from
	reproducoes as R
inner join
	usuarios as U
group by
	U.plano
having
	receita_potencial_total > 1;
    
    
-- Desafio: Crie uma View chamada musicas_populares que mostre:
--    O titulo da música.
--    O artista da música.
--    O número total de vezes que essa música foi reproduzida (total_reproducoes).
--    A view deve mostrar apenas as músicas que foram reproduzidas mais de 2 vezes.
--    Ordene o resultado da view pelo total_reproducoes (do maior para o menor).

create view musicas_populares as
select 
	M.titulo,
    M.artista,
    count(R.id_reproducao) as total_reproducoes
from
	musicas as M
inner join 
	reproducoes as R
group by
	M.titulo, M.artista
having
	total_reproducoes > 2
order by total_reproducoes desc;
	
select * from musicas_populares;

-- Desafio: Crie uma View chamada clientes_premium que mostre:

--    O id_usuario.
--    O nome_usuario.
--    O email do cliente.
--    A view deve incluir apenas clientes com o plano 'Premium'.

create view clientes_premium as 
select 
	id_usuario,
    nome_usuario
from
	usuarios
where
	plano = 'Premium';

select * from clientes_premium

-- O titulo da música.
-- O artista da música.
-- A duracao_segundos da música.
-- Um ranking das músicas com base na duracao_segundos, do menor para o maior. Use a função ROW_NUMBER().
