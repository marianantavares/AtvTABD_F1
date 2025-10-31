/*
 * ARQUIVO: dadosF1.sql
 * DESCRIÇÃO: Script para inserir dados de exemplo em todas as tabelas
 * do banco de dados de estatísticas da Fórmula 1.
 */

-- 1. Inserindo dados em tabelas sem dependências
INSERT INTO Equipes (nome, pais_origem) VALUES
('Mercedes-AMG Petronas', 'Alemanha'), -- ID 1
('Red Bull Racing', 'Áustria'),       -- ID 2
('Scuderia Ferrari', 'Itália');       -- ID 3

INSERT INTO Pilotos (nome_completo, nacionalidade, numero_carro) VALUES
('Lewis Hamilton', 'Reino Unido', 44), -- ID 1
('Max Verstappen', 'Holanda', 1),    -- ID 2
('Charles Leclerc', 'Mônaco', 16);    -- ID 3

INSERT INTO Circuitos (nome_circuito, cidade, pais) VALUES
('Bahrain International Circuit', 'Sakhir', 'Bahrein'), -- ID 1
('Circuit de Monaco', 'Monte Carlo', 'Mônaco'),     -- ID 2
('Silverstone Circuit', 'Silverstone', 'Reino Unido');  -- ID 3

INSERT INTO Tipos_Pneu (nome_pneu) VALUES
('Macio (C3)'),
('Médio (C2)'),
('Duro (C1)');

INSERT INTO Temporadas (ano_temporada, total_corridas) VALUES
(2024, 24); -- ID 1

-- 2. Inserindo dados que dependem da primeira leva (Temporada + Circuitos)
INSERT INTO Corridas (temporada_id, circuito_id, nome_gp, data_corrida, numero_voltas) VALUES
(1, 1, 'Grande Prêmio do Bahrein', '2024-03-02', 57), -- ID 1
(1, 2, 'Grande Prêmio de Mônaco', '2024-05-26', 78); -- ID 2

-- 3. Inserindo Contratos (Piloto + Equipe + Temporada)
INSERT INTO Contratos (temporada_id, piloto_id, equipe_id) VALUES
(1, 1, 1), -- Hamilton na Mercedes em 2024
(1, 2, 2), -- Verstappen na Red Bull em 2024
(1, 3, 3); -- Leclerc na Ferrari em 2024

-- 4. Inserindo Resultados (Corrida + Piloto + Equipe)
-- GP do Bahrein (Corrida 1)
INSERT INTO Resultados_Corrida (corrida_id, piloto_id, equipe_id, posicao_grid, posicao_final, pontos_obtidos, status) VALUES
(1, 2, 2, 1, 1, 26, 'Terminou'), -- Verstappen (ganhou + volta rápida)
(1, 3, 3, 2, 4, 12, 'Terminou'), -- Leclerc
(1, 1, 1, 9, 7, 6, 'Terminou'); -- Hamilton

-- GP de Mônaco (Corrida 2)
INSERT INTO Resultados_Corrida (corrida_id, piloto_id, equipe_id, posicao_grid, posicao_final, pontos_obtidos, status) VALUES
(2, 3, 3, 1, 1, 25, 'Terminou'), -- Leclerc (ganhou em casa)
(2, 2, 2, 6, 6, 8, 'Terminou'), -- Verstappen
(2, 1, 1, 7, 7, 7, 'Terminou'); -- Hamilton (com volta rápida)

-- 5. Inserindo Voltas Rápidas (Corrida + Piloto)
INSERT INTO Voltas_Rapidas (corrida_id, piloto_id, tempo_volta) VALUES
(1, 2, '00:01:32.608'), -- Verstappen no Bahrein
(2, 1, '00:01:14.165'); -- Hamilton em Mônaco

-- 6. Inserindo Pit Stops (Corrida + Piloto + Pneu)
-- Pit stops do Bahrein
INSERT INTO Pit_Stops (corrida_id, piloto_id, volta_pit, duracao_segundos, tipo_pneu_colocado_id) VALUES
(1, 2, 17, 2.5, 3), -- Verstappen (Duro)
(1, 2, 37, 2.3, 3), -- Verstappen (Duro)
(1, 3, 11, 2.8, 3), -- Leclerc (Duro)
(1, 3, 34, 2.6, 3), -- Leclerc (Duro)
(1, 1, 13, 3.1, 3), -- Hamilton (Duro)
(1, 1, 35, 2.9, 1); -- Hamilton (Macio)

-- Pit stops de Mônaco (menos pits)
INSERT INTO Pit_Stops (corrida_id, piloto_id, volta_pit, duracao_segundos, tipo_pneu_colocado_id) VALUES
(2, 3, 1, 2.7, 2), -- Leclerc (foi para Médio logo no início)
(2, 2, 1, 2.4, 2), -- Verstappen (foi para Médio logo no início)
(2, 1, 1, 2.8, 2); -- Hamilton (foi para Médio logo no início)
