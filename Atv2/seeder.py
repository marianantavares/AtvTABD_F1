import psycopg2
import sys

# --- Configurações do Banco de Dados ---
# Use o usuário 'postgres' que já configuramos
DB_NAME = "f1_stats_db"
DB_USER = "postgres"
DB_HOST = "localhost"
DB_PORT = "5432"

def seed_database():
    """
    Popula o banco de dados e verifica a "mágica" do trigger.
    """
    conn = None
    try:
        # 1. Conectar ao banco de dados
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
        )
        cur = conn.cursor()
        print("✅ Conectado ao banco de dados!")

        # 2. Inserir dados básicos (Ordem é importante!)
        print("🏎️  Inserindo equipes e pilotos...")
        cur.execute("""
            INSERT INTO Equipes (equipe_id, nome, pais_origem) VALUES
            (1, 'Mercedes-AMG Petronas', 'Alemanha'),
            (2, 'Red Bull Racing', 'Áustria'),
            (3, 'Scuderia Ferrari', 'Itália')
            ON CONFLICT (equipe_id) DO NOTHING;
        """)
        
        cur.execute("""
            INSERT INTO Pilotos (piloto_id, nome_completo, nacionalidade, numero_carro) VALUES
            (1, 'Lewis Hamilton', 'Reino Unido', 44),
            (2, 'Max Verstappen', 'Holanda', 1),
            (3, 'Charles Leclerc', 'Mônaco', 16)
            ON CONFLICT (piloto_id) DO NOTHING;
        """)

        cur.execute("""
            INSERT INTO Temporadas (temporada_id, ano_temporada, total_corridas) VALUES
            (1, 2024, 24)
            ON CONFLICT (temporada_id) DO NOTHING;
        """)

        cur.execute("""
            INSERT INTO Circuitos (circuito_id, nome_circuito, cidade, pais) VALUES
            (1, 'Bahrain International Circuit', 'Sakhir', 'Bahrein'),
            (2, 'Circuit de Monaco', 'Monte Carlo', 'Mônaco')
            ON CONFLICT (circuito_id) DO NOTHING;
        """)

        cur.execute("""
            INSERT INTO Corridas (corrida_id, temporada_id, circuito_id, nome_gp, data_corrida, numero_voltas) VALUES
            (1, 1, 1, 'Grande Prêmio do Bahrein', '2024-03-02', 57),
            (2, 1, 2, 'Grande Prêmio de Mônaco', '2024-05-26', 78)
            ON CONFLICT (corrida_id) DO NOTHING;
        """)

        # 3. Preparar a tabela de Estatísticas (Passo Crucial!)
        # Temos que inserir os pilotos aqui com valores 'zero'
        # O trigger SÓ FUNCIONA em linhas que JÁ EXISTEM (ele faz UPDATE)
        print("📊 Zerando as estatísticas dos pilotos...")
        cur.execute("""
            INSERT INTO Estatisticas_Piloto (piloto_id, total_vitorias, total_pontos) VALUES
            (1, 0, 0.0),
            (2, 0, 0.0),
            (3, 0, 0.0)
            ON CONFLICT (piloto_id) DO NOTHING;
        """)
        
        # 4. Inserir os Resultados da Corrida (AQUI A MÁGICA ACONTECE!)
        # Cada INSERT abaixo vai disparar o trigger 'trg_atualizar_estatisticas'
        print("🏁 Inserindo resultados... (O TRIGGER ESTÁ SENDO DISPARADO AGORA!)")
        
        # GP do Bahrein (Corrida 1)
        cur.execute("""
            INSERT INTO Resultados_Corrida (corrida_id, piloto_id, equipe_id, posicao_final, pontos_obtidos, status) VALUES
            (1, 2, 2, 1, 25, 'Terminou'), -- Verstappen (Venceu)
            (1, 3, 3, 4, 12, 'Terminou'), -- Leclerc
            (1, 1, 1, 7, 6, 'Terminou');  -- Hamilton
        """)
        
        # GP de Mônaco (Corrida 2)
        cur.execute("""
            INSERT INTO Resultados_Corrida (corrida_id, piloto_id, equipe_id, posicao_final, pontos_obtidos, status) VALUES
            (2, 3, 3, 1, 25, 'Terminou'), -- Leclerc (Venceu)
            (2, 2, 2, 6, 8, 'Terminou'), -- Verstappen
            (2, 1, 1, 7, 6, 'Terminou');  -- Hamilton (nota: pontos diferentes para mesma pos)
        """)

        # 5. Fazer o commit das transações
        conn.commit()
        print("💾 Dados salvos no banco!")

        # 6. VERIFICAR A MÁGICA!
        print("\n\n--- 🌟 RESULTADO DA MÁGICA DO TRIGGER 🌟 ---")
        print("Consultando a tabela 'Estatisticas_Piloto' (que não inserimos diretamente):")
        
        cur.execute("""
            SELECT 
                p.nome_completo, 
                e.total_vitorias, 
                e.total_pontos 
            FROM Estatisticas_Piloto e
            JOIN Pilotos p ON e.piloto_id = p.piloto_id
            ORDER BY e.total_pontos DESC;
        """)
        
        rows = cur.fetchall()
        print("-----------------------------------------------")
        print(f"| {'Piloto':<20} | {'Vitórias':<10} | {'Pontos':<10} |")
        print("-----------------------------------------------")
        for row in rows:
            print(f"| {row[0]:<20} | {row[1]:<10} | {float(row[2]):<10.1f} |")
        print("-----------------------------------------------")


    except psycopg2.Error as e:
        print(f"❌ Erro ao conectar ou popular o banco de dados:")
        print(e)
        if conn:
            conn.rollback() # Desfaz qualquer mudança se der erro
        sys.exit(1) # Sai do script com código de erro

    finally:
        # 7. Fechar a conexão
        if conn:
            cur.close()
            conn.close()
            print("\n✅ Conexão com o banco fechada.")

# --- Ponto de entrada do script ---
if __name__ == "__main__":
    seed_database()