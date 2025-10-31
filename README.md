# Projeto: Estatísticas da F1 (Tópicos Avançados em Banco de Dados)

Este repositório contém duas atividades para a disciplina de Tópicos Avançados em Banco de Dados (TABD), ambas utilizando um schema de estatísticas da Fórmula 1 no PostgreSQL.

* **Atividade 1:** Foco em design de schema complexo e uma consulta analítica avançada (usando CTEs e Window Functions).
* **Atividade 2:** Foco em Triggers e Procedures, demonstrando como o banco pode reagir automaticamente a inserções de dados.

---

##  Pré-requisitos

Antes de executar, garanta que você tem os seguintes componentes instalados e configurados no seu ambiente WSL (Ubuntu):

1.  **PostgreSQL:** O servidor de banco de dados.
    * *Verifique se está em execução:* `sudo systemctl status postgresql`
    * *Se não estiver, inicie:* `sudo systemctl start postgresql`
2.  **Python 3:** A linguagem de script.
3.  **psycopg2 (via APT):** O driver Python para PostgreSQL. É crucial instalá-lo via `apt` para que o usuário `postgres` (usado pelo `sudo`) possa encontrá-lo.
    ```bash
    sudo apt install python3-psycopg2
    ```

---

## Atividade 1: Consulta Complexa

Esta atividade demonstra a criação de um schema relacional e a execução de uma consulta analítica complexa para extrair inteligência dos dados.

**Arquivos utilizados:**
* `schemaF1.sql`
* `dadosF1.sql`
* `consultacomplexa.sql`

### Como Executar e Ver o Resultado

1.  **Crie o banco de dados** (só precisa fazer isso uma vez):
    ```bash
    sudo -u postgres psql -c "CREATE DATABASE f1_stats_db;"
    ```

2.  **Execute o schema** para criar as tabelas:
    ```bash
    sudo -u postgres psql -d f1_stats_db -f 01_schema.sql
    ```

3.  **Popule o banco** com dados de exemplo:
    ```bash
    sudo -u postgres psql -d f1_stats_db -f 02_dados.sql
    ```

4.  **Execute a consulta complexa** para ver o resultado:
    ```bash
    sudo -u postgres psql -d f1_stats_db -f 03_consulta_complexa.sql
    ```

### Resultado Esperado (Atividade 1)

Ao executar o último comando, o terminal exibirá uma tabela formatada, resultado da consulta analítica, mostrando o piloto com a melhor média de tempo de pit stop de cada equipe:

```
       Equipe          | Piloto Mais Rápido (Pits) | Média Pit Stop (s) | Total de Pits | Pneu Mais Utilizado
---------------------+---------------------------+--------------------+---------------+---------------------
 Red Bull Racing     | Max Verstappen            |              2.400 |             2 | Duro (C1)
 Scuderia Ferrari    | Charles Leclerc           |              2.750 |             2 | Duro (C1)
 Mercedes-AMG Petronas | Lewis Hamilton            |              2.950 |             2 | Duro (C1)
(3 rows)
```

---

##  Atividade 2: Trigger

Esta atividade demonstra como um **Trigger** no PostgreSQL pode automatizar tarefas complexas. Um script Python (`seeder.py`) é usado para inserir dados brutos (resultados de corridas), e o trigger,
automaticamente, calcula e atualiza uma tabela de estatísticas agregadas (`Estatisticas_Piloto`).

**Arquivos utilizados:**
* `schemaF1.sql` (A **versão modificada** que inclui a tabela `Estatisticas_Piloto` e o `TRIGGER`)
* `seeder.py`

### Como Executar e Ver o Resultado

1.  **(Opcional) Limpe o banco de dados** anterior para um teste limpo:
    ```bash
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS f1_stats_db;"
    sudo -u postgres psql -c "CREATE DATABASE f1_stats_db;"
    ```

2.  **Execute o novo schema (com trigger)** para criar a estrutura:
    ```bash
    sudo -u postgres psql -d f1_stats_db -f schemaF1.sql
    ```

3.  **Execute o script Python `seeder.py`:**
    O comando abaixo é especial:
    * `cat seeder.py`: Lê o arquivo como seu usuário (`mari`), que tem permissão.
    * `|`: Envia o texto do script para o próximo comando.
    * `sudo -u postgres python3 -`: Executa o script como o usuário `postgres`, que tem permissão para se conectar ao banco (via autenticação `peer`).

    ```bash
    cat seeder.py | sudo -u postgres python3 -
    ```

### Resultado Esperado (Atividade 2)

O script Python irá rodar, se conectar, inserir os dados e, no final, exibir uma tabela de `Estatisticas_Piloto`.

O ponto principal é que o `seeder.py` **não** calcula esses totais; ele apenas insere "0". Os valores de vitórias e pontos são calculados e atualizados **automaticamente pelo trigger** no momento da inserção dos resultados.

```
✅ Conectado ao banco de dados!
🏎️  Inserindo equipes e pilotos...
📊 Zerando as estatísticas dos pilotos...
🏁 Inserindo resultados... (O TRIGGER ESTÁ SENDO DISPARADO AGORA!)
💾 Dados salvos no banco!


---  RESULTADO DO TRIGGER  ---
Consultando a tabela 'Estatisticas_Piloto':
-----------------------------------------------
| Piloto               | Vitórias   | Pontos     |
-----------------------------------------------
| Charles Leclerc      | 1          | 37.0       |
| Max Verstappen       | 1          | 33.0       |
| Lewis Hamilton       | 0          | 12.0       |
-----------------------------------------------

✅ Conexão com o banco fechada.
```