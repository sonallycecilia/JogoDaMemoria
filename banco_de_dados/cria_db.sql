CREATE SCHEMA IF NOT EXISTS sistema_pontuacao;

CREATE TABLE IF NOT EXISTS ranking (
  nome_jogador VARCHAR(50) NOT NULL,
  data_inicio DATE NOT NULL,
  hora_inicio VARCHAR(8) NOT NULL,
  data_final DATE NOT NULL,
  hora_final VARCHAR(8) NOT NULL,
  duracao VARCHAR(8) NOT NULL,
  pontuacao INT NOT NULL,
  dificuldade VARCHAR(20) NOT NULL,
  modo VARCHAR(20) NOT NULL,
  PRIMARY KEY (nome_jogador, data_inicio, hora_inicio)
