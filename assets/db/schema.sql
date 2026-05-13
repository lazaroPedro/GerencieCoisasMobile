CREATE TABLE IF NOT EXISTS "usuarios" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" VARCHAR(255) NOT NULL UNIQUE,
    "password" VARCHAR(128) NOT NULL,
    "email" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "categorias" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" VARCHAR(100) NOT NULL UNIQUE, 
    "parent_id" BIGINT NULL REFERENCES "categorias" ("id")
);


CREATE TABLE IF NOT EXISTS "produtos" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "name" VARCHAR(100) NOT NULL, 
    "description" TEXT NOT NULL, 
    "price" DECIMAL NOT NULL, 
    "supplier" VARCHAR(255) NOT NULL,
    "quantity" INTEGER UNSIGNED NOT NULL CHECK ("quantity" >= 0), 
    "category_id" BIGINT NOT NULL REFERENCES "categorias" ("id")
);


CREATE TABLE IF NOT EXISTS "movimentacoes" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
    "produtos_id" BIGINT NOT NULL REFERENCES "produtos" ("id"),
    "quantity" BIGINT NOT NULL CHECK ("quantity" > 0),
    "value" DECIMAL NOT NULL,
    "entrada_saida" INT NOT NULL CHECK ("entrada_saida" IN (-1, 1))
);