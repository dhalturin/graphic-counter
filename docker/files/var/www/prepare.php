<?php

try {
    $pdo = new PDO($_SERVER['PGSQL_DSN'], $_SERVER['PGSQL_USER'], $_SERVER['PGSQL_PASS']);
} catch (PDOException $e) {
    fwrite(STDERR, 'connection error: ' . $e->getMessage());
    exit(1);
}

try {
    $pdo->query('drop table if exists public.data;');
    $pdo->query('drop sequence if exists public.data_data_id_seq;');
    $pdo->query('CREATE SEQUENCE IF NOT EXISTS data_data_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;');
    $pdo->query('CREATE TABLE IF NOT EXISTS "data" ("data_id" integer DEFAULT nextval(\'data_data_id_seq\'::regclass) NOT NULL, "data_time" integer NOT NULL, "data_ip" bigint NOT NULL );');
} catch (PDOException $e) {
    fwrite(STDERR, 'prepare error: ' . $e->getMessage());
    exit(1);
}

