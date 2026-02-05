import pandas as pd
import requests
from bs4 import BeautifulSoup
from sqlalchemy import create_engine, text
import io

# 1. Conexão ajustada para garantir criação inicial
# Usamos o banco 'master' primeiro para poder criar o 'PaoEPao' se ele não existir
DATABASE_URL_MASTER = "mssql+pyodbc://sa:vL589%Gwd[3@localhost:1433/master?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"
DATABASE_URL_PAO = "mssql+pyodbc://sa:vL589%Gwd[3@localhost:1433/PaoEPao?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"

engine_master = create_engine(DATABASE_URL_MASTER, isolation_level="AUTOCOMMIT")
engine_pao = create_engine(DATABASE_URL_PAO)

# 2. URLs fornecidas pelo desafio
URL_MENU = "https://raw.githubusercontent.com/Valenet-IO/desafio-analista-dados/refs/heads/main/dados/menu.csv"
URL_MEMBROS = "https://raw.githubusercontent.com/Valenet-IO/desafio-analista-dados/refs/heads/main/dados/membros.json"
URL_CLIENTES = "https://raw.githubusercontent.com/Valenet-IO/desafio-analista-dados/refs/heads/main/dados/clientes.json"
URL_VENDAS = "https://raw.githubusercontent.com/Valenet-IO/desafio-analista-dados/refs/heads/main/dados/Vendas.html"

def preparar_infraestrutura():
    print("🛠️ Preparando Banco de Dados...")
    with engine_master.connect() as conn:
        # Cria o banco de dados se não existir
        conn.execute(text("IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PaoEPao') CREATE DATABASE PaoEPao"))
    
    with engine_pao.connect() as conn:
        # Lê o seu arquivo SQL corrigido (sem GO)
        with open('setup_pao_pao.sql', 'r', encoding='utf-8') as f:
            sql_script = f.read()
            # Executa o DDL (Criação de tabelas e FKs)
            for query in sql_script.split(';'):
                if query.strip():
                    conn.execute(text(query))
                    conn.commit()
    print("✅ Tabelas prontas!")

def executar_pipeline():
    preparar_infraestrutura()
    print("🌐 Iniciando extração via HTTP e Web Scraping...")

    # EXTRACAO: Clientes e Membros (JSON via HTTP)
    df_clientes = pd.DataFrame(requests.get(URL_CLIENTES).json()).drop_duplicates()
    df_membros = pd.DataFrame(requests.get(URL_MEMBROS).json()).drop_duplicates()

    # EXTRACAO: Menu (CSV via HTTP) com tratamento semântico
    res_menu = requests.get(URL_MENU)
    df_menu = pd.read_csv(io.StringIO(res_menu.text), sep=';')
    df_menu['preco'] = df_menu['ITEM_PRECO_CENTS'] / 100
    df_menu = df_menu[['ITEM_ID', 'ITEM_NOME', 'preco']]
    df_menu.columns = ['item_id', 'produto', 'preco']
    df_menu = df_menu.drop_duplicates()

    # EXTRACAO: Vendas (Web Scraping puro conforme regra)
    soup = BeautifulSoup(requests.get(URL_VENDAS).text, 'html.parser')
    tabela_html = soup.find('table')
    df_vendas = pd.read_html(io.StringIO(str(tabela_html)))[0]
    
    df_vendas['data_venda'] = pd.to_datetime(
        df_vendas['Data da venda'].str.replace(' as ', ' ').str.replace('h', ':'), 
        dayfirst=True
    )
    df_vendas = df_vendas.rename(columns={'Cliente': 'cliente_nome', 'Produto': 'produto_id'})
    df_vendas = df_vendas[['cliente_nome', 'produto_id', 'data_venda']].drop_duplicates()

    # CARGA (LOAD) - Ordem respeita as Chaves Estrangeiras (FK)
    print("📥 Carregando dados no SQL Server...")
    try:
        df_clientes.to_sql('clientes', engine_pao, if_exists='append', index=False)
        df_menu.to_sql('menu', engine_pao, if_exists='append', index=False)
        df_membros.to_sql('membros', engine_pao, if_exists='append', index=False)
        df_vendas.to_sql('vendas', engine_pao, if_exists='append', index=False)
        print("🚀 Sucesso! Banco PaoEPao populado.")
    except Exception as e:
        print(f"❌ Erro na carga: {e}")

if __name__ == "__main__":
    executar_pipeline()