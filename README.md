# Desafio Tecnico Analista de Dados - Valenet

Este projeto apresenta a solucao para o desafio tecnico da Valenet, envolvendo a estruturacao de um pipeline de dados (ETL) e a criacao de um dashboard gerencial para a Padaria Pao e Pao.

## Instrucoes para Execucao

1. Subir Infraestrutura (Docker):
Execute o comando abaixo para iniciar o container do SQL Server:
docker-compose up -d

2. Preparacao do Ambiente:
Instale as dependencias necessarias do Python:
pip install pandas sqlalchemy pyodbc requests beautifulsoup4

3. Processamento de Dados (ETL):
Execute o script para realizar o web scraping e a carga no banco de dados:
python etl_pao.py

## Estrutura de Arquivos

- etl_pao.py: Script principal de extracao, transformacao e carga.
- setup_pao_pao.sql: Script de criacao das tabelas e modelagem relacional.
- metricas_trimestre.sql: Consultas para validacao de KPIs solicitados.
- **Power BI**: [Clique aqui para baixar o Dashboard (dashpadaria.pbix)](./dashpadaria.pbix).
