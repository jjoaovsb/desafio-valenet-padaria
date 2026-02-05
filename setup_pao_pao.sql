-- 1. Tabela de Clientes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'clientes')
CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nome NVARCHAR(150) NOT NULL,
    deletado BIT DEFAULT 0,
    dt_delete DATETIME NULL
);

-- 2. Tabela de Menu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'menu')
CREATE TABLE menu (
    item_id INT PRIMARY KEY,
    produto NVARCHAR(200) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL
);

-- 3. Tabela de Membros
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'membros')
CREATE TABLE membros (
    id INT PRIMARY KEY,
    cliente_id INT NOT NULL,
    dt_inicio_assinatura DATETIME NOT NULL,
    dt_fim_assinatura DATETIME NULL,
    CONSTRAINT FK_Membros_Clientes FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- 4. Tabela de Vendas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'vendas')
CREATE TABLE vendas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_nome NVARCHAR(150) NOT NULL,
    produto_id INT NOT NULL,
    data_venda DATETIME NOT NULL,
    CONSTRAINT FK_Vendas_Menu FOREIGN KEY (produto_id) REFERENCES menu(item_id)
);