/*
 * ARQUIVO: scheme.sql
 * DESCRIÇÃO: Script para criar todas as tabelas, relacionamentos
 * E OS TRIGGERS para o banco de dados da F1.
 */

-- Reseta o schema 'public' para garantir um ambiente limpo.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Define o timezone padrão
SET TIMEZONE TO 'UTC';

-- SEÇÃO 1: ENTIDADES PRINCIPAIS (Sem alteração)
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
    nome_pneu VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Temporadas (
    temporada_id SERIAL PRIMARY KEY,
    ano_temporada INT NOT NULL UNIQUE CHECK (ano_temporada > 1949),
    total_corridas INT NOT NULL
);

CREATE TABLE Corridas (
    corrida_id SERIAL PRIMARY KEY,
    temporada_id INT NOT NULL REFERENCES Temporadas(temporada_id),
    circuito_id INT NOT NULL REFERENCES Circuitos(circuito_id),
    nome_gp VARCHAR(255) NOT NULL,
    data_corrida DATE NOT NULL,
    numero_voltas INT NOT NULL
);

CREATE TABLE Resultados_Corrida (
    resultado_id SERIAL PRIMARY KEY,
    corrida_id INT NOT NULL REFERENCES Corridas(corrida_id),
    piloto_id INT NOT NULL REFERENCES Pilotos(piloto_id),
    equipe_id INT NOT NULL REFERENCES Equipes(equipe_id),
    posicao_grid INT,
    posicao_final INT,
    pontos_obtidos DECIMAL(4, 1) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL
);

------------------------------------------------------------------
-- 🚀 SEÇÃO 2: NOVIDADES DA ATIVIDADE (TABELA DE ESTATÍSTICAS)
------------------------------------------------------------------

-- Esta tabela será atualizada AUTOMATICAMENTE pelo trigger.
CREATE TABLE Estatisticas_Piloto (
    piloto_id INT PRIMARY KEY REFERENCES Pilotos(piloto_id),
    total_vitorias INT DEFAULT 0,
    total_pontos DECIMAL(6, 1) DEFAULT 0.0
);


------------------------------------------------------------------
-- 🚀 SEÇÃO 3: NOVIDADES DA ATIVIDADE (PROCEDURE E TRIGGER)
------------------------------------------------------------------

-- Passo 1: Criar a PROCEDURE (Função)
-- Esta função contém a lógica que o trigger irá executar.
CREATE OR REPLACE FUNCTION atualizar_estatisticas_piloto()
RETURNS TRIGGER AS $$
BEGIN
    -- 'NEW' refere-se à nova linha que está sendo INSERIDA.

    -- Ação 1: Atualizar o total de pontos do piloto.
    UPDATE Estatisticas_Piloto
    SET total_pontos = total_pontos + NEW.pontos_obtidos
    WHERE piloto_id = NEW.piloto_id;

    -- Ação 2: Se o piloto venceu (posição 1), incrementar suas vitórias.
    IF NEW.posicao_final = 1 THEN
        UPDATE Estatisticas_Piloto
        SET total_vitorias = total_vitorias + 1
        WHERE piloto_id = NEW.piloto_id;
    END IF;

    -- Importante: Retorna o NEW para completar a operação de INSERT.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Passo 2: Criar o TRIGGER
-- Este trigger "amarra" a função à tabela.
CREATE TRIGGER trg_atualizar_estatisticas
    AFTER INSERT ON Resultados_Corrida -- Dispara "depois de um insert"
    FOR EACH ROW                     -- Para cada linha inserida
    EXECUTE FUNCTION atualizar_estatisticas_piloto(); -- Chame esta função