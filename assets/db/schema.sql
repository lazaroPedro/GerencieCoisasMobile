CREATE TABLE IF NOT EXISTS "usuarios" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "password" VARCHAR(128) NOT NULL,
    "email" VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "categorias" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" VARCHAR(100) NOT NULL UNIQUE, 
    "parent_id" BIGINT NULL REFERENCES "categorias" ("id")
);

CREATE TABLE IF NOT EXISTS "fornecedores" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" VARCHAR(100) NOT NULL, 
    "corporate_name" VARCHAR(100) NOT NULL, 
    "cnpj" VARCHAR(20) NOT NULL UNIQUE, 
    "email" VARCHAR(254) NOT NULL, 
    "phone" VARCHAR(20) NOT NULL, 
    "created" DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "produtos" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" VARCHAR(100) NOT NULL, 
    "description" TEXT NOT NULL, 
    "price" DECIMAL NOT NULL, 
    "quantity" INTEGER UNSIGNED NOT NULL CHECK ("quantity" >= 0), 
    "category_id" BIGINT NOT NULL REFERENCES "categorias" ("id")
);

CREATE TABLE IF NOT EXISTS "produtos_fornecedores" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "produto_id" BIGINT NOT NULL REFERENCES "produtos" ("id"), 
    "fornecedor_id" BIGINT NOT NULL REFERENCES "fornecedores" ("id")
);

CREATE TABLE IF NOT EXISTS "movimentacoes" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "produtos_fornecedores_id" BIGINT NOT NULL REFERENCES "produtos_fornecedores" ("id"),
    "quantity" BIGINT NOT NULL CHECK ("quantity" > 0),
    "valor" DECIMAL NOT NULL,
    "entrada_saida" INT NOT NULL CHECK ("entrada_saida" IN (-1, 1))
);