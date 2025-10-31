/*
 * ARQUIVO: schemaF1.sql
 * DESCRIÇÃO: Script para criar todas as tabelas, chaves e relacionamentos
 * do banco de dados de estatísticas da Fórmula 1.
 */

-- Reseta o schema 'public' para garantir um ambiente limpo.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Define o timezone padrão para UTC, que é padrão em eventos globais como a F1.
SET TIMEZONE TO 'UTC';


-- SEÇÃO 1: ENTIDADES PRINCIPAIS (Equipes, Pilotos, Circuitos)

CREATE TABLE Equipes (
    equipe_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    pais_origem VARCHAR(50) NOT NULL
);

CREATE TABLE Pilotos (
    piloto_id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    nacionalidade VARCHAR(50) NOT NULL,
    numero_carro INT NOT NULL UNIQUE
);

CREATE TABLE Circuitos (
    circuito_id SERIAL PRIMARY KEY,
    nome_circuito VARCHAR(255) NOT NULL UNIQUE,
    cidade VARCHAR(100),
    pais VARCHAR(50) NOT NULL
);

CREATE TABLE Tipos_Pneu (
    tipo_pneu_id SERIAL PRIMARY KEY,
    nome_pneu VARCHAR(50) NOT NULL UNIQUE -- Ex: 'Macio', 'Médio', 'Duro', 'Chuva'
);

-- SEÇÃO 2: TEMPORADAS E EVENTOS (O "Calendário")

CREATE TABLE Temporadas (
    temporada_id SERIAL PRIMARY KEY,
    ano_temporada INT NOT NULL UNIQUE CHECK (ano_temporada > 1949),
    total_corridas INT NOT NULL
);

CREATE TABLE Corridas (
    corrida_id SERIAL PRIMARY KEY,
    temporada_id INT NOT NULL REFERENCES Temporadas(temporada_id),
    circuito_id INT NOT NULL REFERENCES Circuitos(circuito_id),
    nome_gp VARCHAR(255) NOT NULL, -- Ex: "Grande Prêmio do Bahrein"
    data_corrida DATE NOT NULL,
    numero_voltas INT NOT NULL
);


-- SEÇÃO 3: TABELAS DE JUNÇÃO (Contratos e Inscrições)

-- Tabela de junção que define qual piloto correu por qual equipe em qual temporada (N-para-N)
CREATE TABLE Contratos (
    contrato_id SERIAL PRIMARY KEY,
    temporada_id INT NOT NULL REFERENCES Temporadas(temporada_id),
    piloto_id INT NOT NULL REFERENCES Pilotos(piloto_id),
    equipe_id INT NOT NULL REFERENCES Equipes(equipe_id),
    -- Garante que um piloto só possa ter um contrato por temporada
    UNIQUE(temporada_id, piloto_id) 
);


-- SEÇÃO 4: RESULTADOS E TELEMETRIA (Os "Fatos")

CREATE TABLE Resultados_Corrida (
    resultado_id SERIAL PRIMARY KEY,
    corrida_id INT NOT NULL REFERENCES Corridas(corrida_id),
    piloto_id INT NOT NULL REFERENCES Pilotos(piloto_id),
    equipe_id INT NOT NULL REFERENCES Equipes(equipe_id), -- Denormalizado para facilitar a consulta
    posicao_grid INT,
    posicao_final INT,
    pontos_obtidos DECIMAL(4, 1) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL, -- 'Terminou', 'DNF', 'Volta Mais Rápida', 'Desclassificado'
    
    -- Garante que um piloto só possa ter um resultado por corrida
    UNIQUE(corrida_id, piloto_id)
);

CREATE TABLE Pit_Stops (
    pit_stop_id SERIAL PRIMARY KEY,
    corrida_id INT NOT NULL REFERENCES Corridas(corrida_id),
    piloto_id INT NOT NULL REFERENCES Pilotos(piloto_id),
    volta_pit INT NOT NULL,
    duracao_segundos DECIMAL(5, 3) NOT NULL, -- Ex: 2.145 segundos
    tipo_pneu_colocado_id INT NOT NULL REFERENCES Tipos_Pneu(tipo_pneu_id)
);

-- Tabela para registrar a volta mais rápida de cada corrida (relação 1-para-1 com Corrida)
CREATE TABLE Voltas_Rapidas (
    volta_rapida_id SERIAL PRIMARY KEY,
    corrida_id INT NOT NULL UNIQUE REFERENCES Corridas(corrida_id),
    piloto_id INT NOT NULL REFERENCES Pilotos(piloto_id),
    tempo_volta INTERVAL NOT NULL -- Tipo de dado ideal para guardar "1:23.456"
);
