/*
 * ARQUIVO: consulta_complexa.sql
 * 
 */

--  QUERY:
-- "Qual piloto de cada equipe teve a melhor média de tempo de pit stop
--  na temporada? Para esse piloto, mostre também o total de pit stops
--  realizados e o tipo de pneu que ele mais utilizou."

WITH
  -- Passo 1: Calcular a média e o total de pit stops para cada piloto.
  StatsPitStopPiloto AS (
    SELECT
      r.piloto_id,
      r.equipe_id,
      AVG(ps.duracao_segundos) AS media_pit_stop,
      COUNT(ps.pit_stop_id) AS total_pit_stops
    FROM Pit_Stops AS ps
    -- Usamos Resultados_Corrida para ligar o Pit_Stop (piloto_id) à Equipe daquele ano.
    JOIN Resultados_Corrida AS r ON ps.piloto_id = r.piloto_id AND ps.corrida_id = r.corrida_id
    GROUP BY
      r.piloto_id,
      r.equipe_id
  ),

  -- Passo 2: Descobrir o pneu mais usado por cada piloto.
  ContagemPneusPiloto AS (
    SELECT
      ps.piloto_id,
      tp.nome_pneu,
      COUNT(tp.tipo_pneu_id) AS contagem_uso,
      -- Função de Janela (WINDOW FUNCTION): Numera o uso de pneus para cada piloto.
      -- O 'rn = 1' será o pneu mais usado.
      ROW_NUMBER() OVER (
        PARTITION BY ps.piloto_id
        ORDER BY COUNT(tp.tipo_pneu_id) DESC
      ) AS rn_pneu
    FROM Pit_Stops AS ps
    JOIN Tipos_Pneu AS tp ON ps.tipo_pneu_colocado_id = tp.tipo_pneu_id
    GROUP BY
      ps.piloto_id,
      tp.nome_pneu
  ),
  
  -- Passo 3: Filtrar apenas o pneu mais usado (rn = 1) do passo anterior.
  PneuMaisUsado AS (
    SELECT
      piloto_id,
      nome_pneu
    FROM ContagemPneusPiloto
    WHERE rn_pneu = 1
  ),

  -- Passo 4: Rankear os pilotos DENTRO de cada equipe pela sua média de pit stop.
  RankingPilotosPorEquipe AS (
    SELECT
      s.piloto_id,
      s.equipe_id,
      s.media_pit_stop,
      s.total_pit_stops,
      -- Função de Janela (WINDOW FUNCTION): Particiona por equipe
      -- e ordena pela média de tempo (ASC = mais rápido).
      ROW_NUMBER() OVER (
        PARTITION BY s.equipe_id
        ORDER BY s.media_pit_stop ASC
      ) AS ranking_na_equipe
    FROM StatsPitStopPiloto AS s
  )

-- Passo Final: Selecionar apenas o piloto ranking 1 de cada equipe
-- e juntar com as informações das outras CTEs.
SELECT
  e.nome AS "Equipe",
  p.nome_completo AS "Piloto Mais Rápido (Pits)",
  ROUND(r.media_pit_stop, 3) AS "Média Pit Stop (s)",
  r.total_pit_stops AS "Total de Pits",
  pmu.nome_pneu AS "Pneu Mais Utilizado"
FROM RankingPilotosPorEquipe AS r
JOIN Pilotos AS p ON r.piloto_id = p.piloto_id
JOIN Equipes AS e ON r.equipe_id = e.equipe_id
JOIN PneuMaisUsado AS pmu ON r.piloto_id = pmu.piloto_id
WHERE
  r.ranking_na_equipe = 1
ORDER BY
  "Média Pit Stop (s)" ASC;
