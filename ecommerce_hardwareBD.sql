
-- =========================================================
-- ECOMMERCE HARDWARE DATABASE
-- PROJETO COMPLETO - MYSQL WORKBENCH
-- =========================================================

DROP DATABASE IF EXISTS ecommerce_hardware;
CREATE DATABASE ecommerce_hardware;
USE ecommerce_hardware;

SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- CLIENTE
-- =========================================================

CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    cpf CHAR(11) NOT NULL UNIQUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_cliente_nome(nome),
    INDEX idx_cliente_email(email),
    INDEX idx_cliente_cpf(cpf)
) ENGINE=InnoDB;

CREATE TABLE ENDERECO (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,

    rua VARCHAR(150) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,

    tipo ENUM('ENTREGA', 'COBRANCA') NOT NULL,

    CONSTRAINT fk_endereco_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON DELETE CASCADE,

    INDEX idx_endereco_cliente(id_cliente),
    INDEX idx_endereco_cep(cep)
) ENGINE=InnoDB;

-- =========================================================
-- PRODUTOS
-- =========================================================

CREATE TABLE CATEGORIA (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,

    INDEX idx_categoria_nome(nome)
) ENGINE=InnoDB;

CREATE TABLE MARCA (
    id_marca INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,

    INDEX idx_marca_nome(nome)
) ENGINE=InnoDB;

CREATE TABLE PRODUTO (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,

    nome VARCHAR(150) NOT NULL,
    descricao TEXT,

    preco DECIMAL(10,2) NOT NULL,

    status ENUM('ATIVO', 'INATIVO') DEFAULT 'ATIVO',

    id_categoria INT NOT NULL,
    id_marca INT NOT NULL,

    CONSTRAINT chk_preco_produto
        CHECK (preco >= 0),

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA(id_categoria),

    CONSTRAINT fk_produto_marca
        FOREIGN KEY (id_marca)
        REFERENCES MARCA(id_marca),

    INDEX idx_produto_nome(nome),
    INDEX idx_produto_preco(preco),
    INDEX idx_produto_categoria(id_categoria),
    INDEX idx_produto_marca(id_marca)
) ENGINE=InnoDB;

-- =========================================================
-- ESPECIFICACOES
-- =========================================================

CREATE TABLE TIPOESPECIFICACAO (
    id_tipo_especificacao INT AUTO_INCREMENT PRIMARY KEY,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,

    INDEX idx_tipo_especificacao_nome(nome)
) ENGINE=InnoDB;

CREATE TABLE VALORESPECIFICACAO (
    id_valor_especificacao INT AUTO_INCREMENT PRIMARY KEY,

    id_tipo_especificacao INT NOT NULL,
    valor VARCHAR(100) NOT NULL,

    CONSTRAINT uq_valor_especificacao
        UNIQUE(id_tipo_especificacao, valor),

    CONSTRAINT fk_valorespecificacao_tipo
        FOREIGN KEY (id_tipo_especificacao)
        REFERENCES TIPOESPECIFICACAO(id_tipo_especificacao),

    INDEX idx_valor_especificacao_tipo(id_tipo_especificacao),
    INDEX idx_valor_especificacao_valor(valor)
) ENGINE=InnoDB;

CREATE TABLE PRODUTOESPECIFICACAO (
    id_produto_especificacao INT AUTO_INCREMENT PRIMARY KEY,

    id_produto INT NOT NULL,
    id_tipo_especificacao INT NOT NULL,
    id_valor_especificacao INT NOT NULL,

    CONSTRAINT uq_produto_especificacao
        UNIQUE(id_produto, id_tipo_especificacao),

    CONSTRAINT fk_produtoespecificacao_produto
        FOREIGN KEY (id_produto)
        REFERENCES PRODUTO(id_produto)
        ON DELETE CASCADE,

    CONSTRAINT fk_produtoespecificacao_tipo
        FOREIGN KEY (id_tipo_especificacao)
        REFERENCES TIPOESPECIFICACAO(id_tipo_especificacao),

    CONSTRAINT fk_produtoespecificacao_valor
        FOREIGN KEY (id_valor_especificacao)
        REFERENCES VALORESPECIFICACAO(id_valor_especificacao),

    INDEX idx_pe_produto(id_produto),
    INDEX idx_pe_tipo(id_tipo_especificacao),
    INDEX idx_pe_valor(id_valor_especificacao)
) ENGINE=InnoDB;

-- =========================================================
-- CARRINHO
-- =========================================================

CREATE TABLE CARRINHO (
    id_carrinho INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL UNIQUE,

    CONSTRAINT fk_carrinho_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON DELETE CASCADE,

    INDEX idx_carrinho_cliente(id_cliente)
) ENGINE=InnoDB;

CREATE TABLE ITEMCARRINHO (
    id_item INT AUTO_INCREMENT PRIMARY KEY,

    id_carrinho INT NOT NULL,
    id_produto INT NOT NULL,

    quantidade INT NOT NULL,

    CONSTRAINT chk_quantidade_itemcarrinho
        CHECK (quantidade > 0),

    CONSTRAINT fk_itemcarrinho_carrinho
        FOREIGN KEY (id_carrinho)
        REFERENCES CARRINHO(id_carrinho)
        ON DELETE CASCADE,

    CONSTRAINT fk_itemcarrinho_produto
        FOREIGN KEY (id_produto)
        REFERENCES PRODUTO(id_produto),

    CONSTRAINT uq_item_carrinho
        UNIQUE(id_carrinho, id_produto),

    INDEX idx_itemcarrinho_carrinho(id_carrinho),
    INDEX idx_itemcarrinho_produto(id_produto)
) ENGINE=InnoDB;

-- =========================================================
-- PEDIDOS
-- =========================================================

CREATE TABLE PEDIDO (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL,

    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    status ENUM(
        'PENDENTE',
        'PAGO',
        'ENVIADO',
        'ENTREGUE',
        'CANCELADO'
    ) DEFAULT 'PENDENTE',

    valor_total DECIMAL(10,2) DEFAULT 0,

    CONSTRAINT chk_valor_total_pedido
        CHECK (valor_total >= 0),

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),

    INDEX idx_pedido_cliente(id_cliente),
    INDEX idx_pedido_status(status),
    INDEX idx_pedido_data(data_pedido)
) ENGINE=InnoDB;

CREATE TABLE ITEMPEDIDO (
    id_item INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,

    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_quantidade_itempedido
        CHECK (quantidade > 0),

    CONSTRAINT chk_preco_unitario
        CHECK (preco_unitario >= 0),

    CONSTRAINT fk_itempedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido)
        ON DELETE CASCADE,

    CONSTRAINT fk_itempedido_produto
        FOREIGN KEY (id_produto)
        REFERENCES PRODUTO(id_produto),

    INDEX idx_itempedido_pedido(id_pedido),
    INDEX idx_itempedido_produto(id_produto)
) ENGINE=InnoDB;

CREATE TABLE PAGAMENTO (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL UNIQUE,

    tipo ENUM(
        'PIX',
        'CARTAO',
        'BOLETO'
    ) NOT NULL,

    status ENUM(
        'PENDENTE',
        'APROVADO',
        'RECUSADO'
    ) DEFAULT 'PENDENTE',

    valor DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_valor_pagamento
        CHECK (valor >= 0),

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido)
        ON DELETE CASCADE,

    INDEX idx_pagamento_pedido(id_pedido),
    INDEX idx_pagamento_status(status)
) ENGINE=InnoDB;

CREATE TABLE ENVIO (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL UNIQUE,
    id_endereco INT NOT NULL,

    status ENUM(
        'PREPARANDO',
        'ENVIADO',
        'ENTREGUE'
    ) DEFAULT 'PREPARANDO',

    codigo_rastreio VARCHAR(100),

    CONSTRAINT fk_envio_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido)
        ON DELETE CASCADE,

    CONSTRAINT fk_envio_endereco
        FOREIGN KEY (id_endereco)
        REFERENCES ENDERECO(id_endereco),

    INDEX idx_envio_pedido(id_pedido),
    INDEX idx_envio_status(status)
) ENGINE=InnoDB;

-- =========================================================
-- ESTOQUE
-- =========================================================

CREATE TABLE ESTOQUE (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,

    id_produto INT NOT NULL UNIQUE,

    quantidade INT NOT NULL DEFAULT 0,

    localizacao VARCHAR(100),

    CONSTRAINT chk_quantidade_estoque
        CHECK (quantidade >= 0),

    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto)
        REFERENCES PRODUTO(id_produto)
        ON DELETE CASCADE,

    INDEX idx_estoque_produto(id_produto),
    INDEX idx_estoque_quantidade(quantidade)
) ENGINE=InnoDB;

-- =========================================================
-- AVALIACAO
-- =========================================================

CREATE TABLE AVALIACAO (
    id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL,
    id_produto INT NOT NULL,

    nota INT NOT NULL,
    comentario TEXT,

    CONSTRAINT chk_nota_avaliacao
        CHECK (nota BETWEEN 1 AND 5),

    CONSTRAINT fk_avaliacao_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON DELETE CASCADE,

    CONSTRAINT fk_avaliacao_produto
        FOREIGN KEY (id_produto)
        REFERENCES PRODUTO(id_produto)
        ON DELETE CASCADE,

    INDEX idx_avaliacao_cliente(id_cliente),
    INDEX idx_avaliacao_produto(id_produto),
    INDEX idx_avaliacao_nota(nota)
) ENGINE=InnoDB;

-- =========================================================
-- COMPATIBILIDADE
-- =========================================================

CREATE TABLE COMPATIBILIDADE (
    id_compatibilidade INT AUTO_INCREMENT PRIMARY KEY,

    id_produto1 INT NOT NULL,
    id_produto2 INT NOT NULL,

    tipo_regra ENUM(
        'COMPATIVEL',
        'INCOMPATIVEL'
    ) NOT NULL,

    descricao TEXT,

    CONSTRAINT chk_produtos_diferentes
        CHECK (id_produto1 <> id_produto2),

    CONSTRAINT uq_compatibilidade
        UNIQUE(id_produto1, id_produto2),

    CONSTRAINT fk_compatibilidade_produto1
        FOREIGN KEY (id_produto1)
        REFERENCES PRODUTO(id_produto),

    CONSTRAINT fk_compatibilidade_produto2
        FOREIGN KEY (id_produto2)
        REFERENCES PRODUTO(id_produto),

    INDEX idx_compatibilidade_p1(id_produto1),
    INDEX idx_compatibilidade_p2(id_produto2)
) ENGINE=InnoDB;

-- =========================================================
-- INSERTS BASE
-- =========================================================

INSERT INTO CATEGORIA (nome) VALUES
('Processador'),
('Placa-mae'),
('Placa de Video'),
('Memoria RAM'),
('SSD'),
('HD'),
('Fonte'),
('Gabinete'),
('Cooler'),
('Monitor');

INSERT INTO MARCA (nome) VALUES
('AMD'),
('Intel'),
('NVIDIA'),
('ASUS'),
('Gigabyte'),
('MSI'),
('Corsair'),
('Kingston'),
('Samsung'),
('Cooler Master');

INSERT INTO TIPOESPECIFICACAO (nome, descricao) VALUES
('Socket', 'Socket do processador'),
('Chipset', 'Chipset da placa-mae'),
('Memoria', 'Tipo de memoria'),
('PCIe', 'Versao PCI Express'),
('Potencia', 'Potencia da fonte');

INSERT INTO VALORESPECIFICACAO (id_tipo_especificacao, valor) VALUES
(1, 'AM4'),
(1, 'AM5'),
(1, 'LGA1700'),
(2, 'B450'),
(2, 'B550'),
(2, 'X570'),
(2, 'Z790'),
(3, 'DDR4'),
(3, 'DDR5'),
(4, 'PCIe 4.0'),
(4, 'PCIe 5.0'),
(5, '500W'),
(5, '650W'),
(5, '750W');

-- =========================================================
-- 50+ PRODUTOS
-- =========================================================

INSERT INTO PRODUTO (nome, descricao, preco, id_categoria, id_marca) VALUES
('Ryzen 3 3200G', 'CPU AMD AM4', 499.90, 1, 1),
('Ryzen 5 3600', 'CPU AMD AM4', 699.90, 1, 1),
('Ryzen 5 4500', 'CPU AMD AM4', 799.90, 1, 1),
('Ryzen 5 4600G', 'CPU AMD AM4', 849.90, 1, 1),
('Ryzen 5 5500', 'CPU AMD AM4', 899.90, 1, 1),
('Ryzen 5 5600', 'CPU AMD AM4', 999.90, 1, 1),
('Ryzen 5 5600X', 'CPU AMD AM4', 1199.90, 1, 1),
('Ryzen 7 5700X', 'CPU AMD AM4', 1499.90, 1, 1),
('Ryzen 7 5800X', 'CPU AMD AM4', 1799.90, 1, 1),
('Ryzen 9 5900X', 'CPU AMD AM4', 2599.90, 1, 1),
('Intel i3 10100F', 'CPU Intel', 499.90, 1, 2),
('Intel i5 10400F', 'CPU Intel', 699.90, 1, 2),
('Intel i5 11400F', 'CPU Intel', 899.90, 1, 2),
('Intel i5 12400F', 'CPU Intel', 1099.90, 1, 2),
('Intel i5 13400F', 'CPU Intel', 1399.90, 1, 2),
('Intel i7 12700K', 'CPU Intel', 2399.90, 1, 2),
('Intel i7 13700K', 'CPU Intel', 2899.90, 1, 2),
('Intel i9 13900K', 'CPU Intel', 4299.90, 1, 2),
('RTX 3050', 'GPU NVIDIA', 1499.90, 3, 3),
('RTX 3060', 'GPU NVIDIA', 1999.90, 3, 3),
('RTX 3060 Ti', 'GPU NVIDIA', 2399.90, 3, 3),
('RTX 3070', 'GPU NVIDIA', 2999.90, 3, 3),
('RTX 3070 Ti', 'GPU NVIDIA', 3499.90, 3, 3),
('RTX 3080', 'GPU NVIDIA', 4999.90, 3, 3),
('RTX 3090', 'GPU NVIDIA', 7999.90, 3, 3),
('RTX 4060', 'GPU NVIDIA', 2499.90, 3, 3),
('RTX 4070', 'GPU NVIDIA', 3999.90, 3, 3),
('RTX 4080', 'GPU NVIDIA', 7999.90, 3, 3),
('RTX 4090', 'GPU NVIDIA', 12999.90, 3, 3),
('RX 6600', 'GPU AMD', 1599.90, 3, 1),
('RX 6700 XT', 'GPU AMD', 2599.90, 3, 1),
('RX 7600', 'GPU AMD', 2299.90, 3, 1),
('RX 7700 XT', 'GPU AMD', 3599.90, 3, 1),
('RX 7900 XT', 'GPU AMD', 6999.90, 3, 1),
('ASUS Prime B450M', 'Placa mae AM4', 599.90, 2, 4),
('ASUS TUF B550M', 'Placa mae AM4', 999.90, 2, 4),
('Gigabyte B450M', 'Placa mae AM4', 649.90, 2, 5),
('Gigabyte B550 Aorus', 'Placa mae AM4', 1199.90, 2, 5),
('MSI X570 Gaming', 'Placa mae AM4', 1699.90, 2, 6),
('MSI Z790', 'Placa mae Intel', 2299.90, 2, 6),
('Corsair Vengeance 16GB DDR4', 'RAM DDR4', 349.90, 4, 7),
('Corsair Vengeance 32GB DDR5', 'RAM DDR5', 799.90, 4, 7),
('Kingston Fury 16GB DDR4', 'RAM DDR4', 329.90, 4, 8),
('Kingston Fury 32GB DDR5', 'RAM DDR5', 749.90, 4, 8),
('Samsung 980 1TB', 'SSD NVMe', 499.90, 5, 9),
('Samsung 990 Pro 2TB', 'SSD NVMe', 1299.90, 5, 9),
('Corsair CV550', 'Fonte 550W', 349.90, 7, 7),
('Corsair RM750x', 'Fonte 750W', 699.90, 7, 7),
('Cooler Master 650W', 'Fonte 650W', 449.90, 7, 10),
('Cooler Master Hyper 212', 'Air Cooler', 249.90, 9, 10),
('Cooler Master MasterBox', 'Gabinete', 399.90, 8, 10);

-- =========================================================
-- 50 CLIENTES
-- =========================================================

INSERT INTO CLIENTE (nome, email, telefone, cpf) VALUES
('Cliente 1','cliente1@email.com','81999990001','00000000001'),
('Cliente 2','cliente2@email.com','81999990002','00000000002'),
('Cliente 3','cliente3@email.com','81999990003','00000000003'),
('Cliente 4','cliente4@email.com','81999990004','00000000004'),
('Cliente 5','cliente5@email.com','81999990005','00000000005'),
('Cliente 6','cliente6@email.com','81999990006','00000000006'),
('Cliente 7','cliente7@email.com','81999990007','00000000007'),
('Cliente 8','cliente8@email.com','81999990008','00000000008'),
('Cliente 9','cliente9@email.com','81999990009','00000000009'),
('Cliente 10','cliente10@email.com','81999990010','00000000010'),
('Cliente 11','cliente11@email.com','81999990011','00000000011'),
('Cliente 12','cliente12@email.com','81999990012','00000000012'),
('Cliente 13','cliente13@email.com','81999990013','00000000013'),
('Cliente 14','cliente14@email.com','81999990014','00000000014'),
('Cliente 15','cliente15@email.com','81999990015','00000000015'),
('Cliente 16','cliente16@email.com','81999990016','00000000016'),
('Cliente 17','cliente17@email.com','81999990017','00000000017'),
('Cliente 18','cliente18@email.com','81999990018','00000000018'),
('Cliente 19','cliente19@email.com','81999990019','00000000019'),
('Cliente 20','cliente20@email.com','81999990020','00000000020'),
('Cliente 21','cliente21@email.com','81999990021','00000000021'),
('Cliente 22','cliente22@email.com','81999990022','00000000022'),
('Cliente 23','cliente23@email.com','81999990023','00000000023'),
('Cliente 24','cliente24@email.com','81999990024','00000000024'),
('Cliente 25','cliente25@email.com','81999990025','00000000025'),
('Cliente 26','cliente26@email.com','81999990026','00000000026'),
('Cliente 27','cliente27@email.com','81999990027','00000000027'),
('Cliente 28','cliente28@email.com','81999990028','00000000028'),
('Cliente 29','cliente29@email.com','81999990029','00000000029'),
('Cliente 30','cliente30@email.com','81999990030','00000000030'),
('Cliente 31','cliente31@email.com','81999990031','00000000031'),
('Cliente 32','cliente32@email.com','81999990032','00000000032'),
('Cliente 33','cliente33@email.com','81999990033','00000000033'),
('Cliente 34','cliente34@email.com','81999990034','00000000034'),
('Cliente 35','cliente35@email.com','81999990035','00000000035'),
('Cliente 36','cliente36@email.com','81999990036','00000000036'),
('Cliente 37','cliente37@email.com','81999990037','00000000037'),
('Cliente 38','cliente38@email.com','81999990038','00000000038'),
('Cliente 39','cliente39@email.com','81999990039','00000000039'),
('Cliente 40','cliente40@email.com','81999990040','00000000040'),
('Cliente 41','cliente41@email.com','81999990041','00000000041'),
('Cliente 42','cliente42@email.com','81999990042','00000000042'),
('Cliente 43','cliente43@email.com','81999990043','00000000043'),
('Cliente 44','cliente44@email.com','81999990044','00000000044'),
('Cliente 45','cliente45@email.com','81999990045','00000000045'),
('Cliente 46','cliente46@email.com','81999990046','00000000046'),
('Cliente 47','cliente47@email.com','81999990047','00000000047'),
('Cliente 48','cliente48@email.com','81999990048','00000000048'),
('Cliente 49','cliente49@email.com','81999990049','00000000049'),
('Cliente 50','cliente50@email.com','81999990050','00000000050');

-- =========================================================
-- TRIGGERS
-- =========================================================

DELIMITER $$

CREATE TRIGGER trg_atualizar_estoque
AFTER INSERT ON ITEMPEDIDO
FOR EACH ROW
BEGIN
    UPDATE ESTOQUE
    SET quantidade = quantidade - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_calcular_valor_pedido
AFTER INSERT ON ITEMPEDIDO
FOR EACH ROW
BEGIN
    UPDATE PEDIDO
    SET valor_total = (
        SELECT SUM(quantidade * preco_unitario)
        FROM ITEMPEDIDO
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
END $$

DELIMITER ;

-- =========================================================
-- 15 SELECTS SIMPLES
-- =========================================================

SELECT * FROM PRODUTO;
SELECT * FROM CLIENTE;
SELECT * FROM PEDIDO;
SELECT * FROM ESTOQUE;
SELECT * FROM AVALIACAO;
SELECT * FROM PAGAMENTO;
SELECT * FROM ENVIO;
SELECT * FROM CATEGORIA;
SELECT * FROM MARCA;
SELECT nome FROM PRODUTO;
SELECT preco FROM PRODUTO;
SELECT nome FROM CLIENTE;
SELECT status FROM PEDIDO;
SELECT codigo_rastreio FROM ENVIO;
SELECT * FROM COMPATIBILIDADE;

-- =========================================================
-- 15 SELECTS COM FILTRO
-- =========================================================

SELECT * FROM PRODUTO WHERE preco > 3000;
SELECT * FROM PRODUTO WHERE preco < 1000;
SELECT * FROM PRODUTO WHERE nome LIKE '%RTX%';
SELECT * FROM PRODUTO WHERE nome LIKE '%Ryzen%';
SELECT * FROM PEDIDO WHERE status = 'PAGO';
SELECT * FROM CLIENTE WHERE nome LIKE 'Cliente 1%';
SELECT * FROM ESTOQUE WHERE quantidade < 10;
SELECT * FROM PAGAMENTO WHERE tipo = 'PIX';
SELECT * FROM ENVIO WHERE status = 'ENVIADO';
SELECT * FROM PRODUTO WHERE id_categoria = 1;
SELECT * FROM PRODUTO WHERE id_categoria = 3;
SELECT * FROM PRODUTO WHERE id_marca = 1;
SELECT * FROM PRODUTO WHERE id_marca = 3;
SELECT * FROM AVALIACAO WHERE nota = 5;
SELECT * FROM PEDIDO WHERE valor_total > 1000;

-- =========================================================
-- 10 JOINS
-- =========================================================

SELECT p.nome, c.nome AS categoria
FROM PRODUTO p
JOIN CATEGORIA c
ON p.id_categoria = c.id_categoria;

SELECT p.nome, m.nome AS marca
FROM PRODUTO p
JOIN MARCA m
ON p.id_marca = m.id_marca;

SELECT cl.nome, pe.id_pedido
FROM CLIENTE cl
JOIN PEDIDO pe
ON cl.id_cliente = pe.id_cliente;

SELECT pr.nome, e.quantidade
FROM PRODUTO pr
JOIN ESTOQUE e
ON pr.id_produto = e.id_produto;

SELECT p.nome, a.nota
FROM PRODUTO p
JOIN AVALIACAO a
ON p.id_produto = a.id_produto;

SELECT pe.id_pedido, pg.tipo
FROM PEDIDO pe
JOIN PAGAMENTO pg
ON pe.id_pedido = pg.id_pedido;

SELECT pe.id_pedido, en.status
FROM PEDIDO pe
JOIN ENVIO en
ON pe.id_pedido = en.id_pedido;

SELECT p.nome, ve.valor
FROM PRODUTO p
JOIN PRODUTOESPECIFICACAO pe
ON p.id_produto = pe.id_produto
JOIN VALORESPECIFICACAO ve
ON pe.id_valor_especificacao = ve.id_valor_especificacao;

SELECT c.nome, COUNT(p.id_produto)
FROM CATEGORIA c
JOIN PRODUTO p
ON c.id_categoria = p.id_categoria
GROUP BY c.nome;

SELECT m.nome, COUNT(p.id_produto)
FROM MARCA m
JOIN PRODUTO p
ON m.id_marca = p.id_marca
GROUP BY m.nome;

-- =========================================================
-- AGREGACOES
-- =========================================================

SELECT COUNT(*) AS total_produtos FROM PRODUTO;
SELECT COUNT(*) AS total_clientes FROM CLIENTE;
SELECT COUNT(*) AS total_pedidos FROM PEDIDO;

SELECT SUM(valor_total) AS faturamento FROM PEDIDO;
SELECT SUM(quantidade) AS estoque_total FROM ESTOQUE;
SELECT SUM(valor) AS total_pagamentos FROM PAGAMENTO;

SELECT AVG(preco) AS media_preco FROM PRODUTO;
SELECT AVG(nota) AS media_avaliacao FROM AVALIACAO;
SELECT AVG(valor_total) AS ticket_medio FROM PEDIDO;

-- =========================================================
-- 10 UPDATES
-- =========================================================

UPDATE PRODUTO SET preco = 1099.90 WHERE id_produto = 1;
UPDATE PRODUTO SET preco = 1199.90 WHERE id_produto = 2;
UPDATE PRODUTO SET preco = 1299.90 WHERE id_produto = 3;
UPDATE PRODUTO SET preco = 1399.90 WHERE id_produto = 4;
UPDATE PRODUTO SET preco = 1499.90 WHERE id_produto = 5;
UPDATE PEDIDO SET status = 'ENVIADO' WHERE id_pedido = 1;
UPDATE PEDIDO SET status = 'ENTREGUE' WHERE id_pedido = 2;
UPDATE ESTOQUE SET quantidade = 20 WHERE id_produto = 1;
UPDATE ESTOQUE SET quantidade = 15 WHERE id_produto = 2;
UPDATE CLIENTE SET telefone = '81911111111' WHERE id_cliente = 1;

-- =========================================================
-- 10 DELETES
-- =========================================================

DELETE FROM ITEMCARRINHO WHERE id_item = 1;
DELETE FROM ITEMCARRINHO WHERE id_item = 2;
DELETE FROM ITEMCARRINHO WHERE id_item = 3;
DELETE FROM ITEMCARRINHO WHERE id_item = 4;
DELETE FROM ITEMCARRINHO WHERE id_item = 5;
DELETE FROM AVALIACAO WHERE id_avaliacao = 1;
DELETE FROM AVALIACAO WHERE id_avaliacao = 2;
DELETE FROM AVALIACAO WHERE id_avaliacao = 3;
DELETE FROM AVALIACAO WHERE id_avaliacao = 4;
DELETE FROM AVALIACAO WHERE id_avaliacao = 5;

SET FOREIGN_KEY_CHECKS = 1;


