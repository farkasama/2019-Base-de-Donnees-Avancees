DROP TABLE IF EXISTS Prospect;
DROP TABLE IF EXISTS Gestionnaire;
DROP TABLE IF EXISTS Message_Utilisateur;
DROP TABLE IF EXISTS Message_Beneficiaire;
DROP TABLE IF EXISTS Categorie;
DROP TABLE IF EXISTS Objectif;
DROP TABLE IF EXISTS Temps;
DROP TABLE IF EXISTS Transaction;
DROP TABLE IF EXISTS Projet;
DROP TABLE IF EXISTS Utilisateur;
DROP TABLE IF EXISTS Beneficiaire;

CREATE TABLE Temps (
    date_actuelle TIMESTAMP PRIMARY KEY
);

CREATE TABLE  Beneficiaire(
    pseudo VARCHAR(50) PRIMARY KEY ,
    nom VARCHAR (255) UNIQUE NOT NULL ,
    prenom VARCHAR (255) UNIQUE NOT NULL,
    mdp VARCHAR (50) NOT NULL,
    nom_de_scene VARCHAR (255) NOT NULL,
    descri TEXT
);

CREATE TABLE Utilisateur(
    pseudo VARCHAR(50) PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255) NOT NULL,
    mdp VARCHAR(50) NOT NULL,
    solde FLOAT NOT NULL CHECK (solde > 0)
);

CREATE TABLE Projet(
    id_projet SERIAL PRIMARY KEY,
    titre VARCHAR(50) NOT NULL,
    descri TEXT NOT NULL,
    date_fin TIMESTAMP NOT NULL CHECK ( date_fin >= CURRENT_DATE ),
    montant_atteindre INTEGER NOT NULL,
    type_de_projet VARCHAR(255),
    pseudo_beneficiaire VARCHAR(50) NOT NULL,
    CONSTRAINT projet_user_fk FOREIGN KEY (pseudo_beneficiaire)
        REFERENCES Beneficiaire(pseudo)
);

CREATE TABLE Transaction(
    id_transaction SERIAL PRIMARY KEY ,
    montant FLOAT CHECK (montant > 0 ),
    frais_de_gestion FLOAT CHECK (frais_de_gestion > 0) ,
    id_projet INTEGER NOT NULL,
    pseudo_utilisateur VARCHAR(50),
    date_transaction TIMESTAMP NOT NULL,
    pret_rembourse BOOLEAN NOT NULL, -- false = pas rembourser, true = rembourser
    statut INTEGER NOT NULL CHECK ( statut >= 0 AND statut <=2 ), --0 = en attente, 1 = preleve, 2 = rembourser
    type_don BOOLEAN NOT NULL, --true = pret, false = don

    CONSTRAINT transaction_fk FOREIGN KEY(id_projet)
        REFERENCES  Projet(id_projet),

    CONSTRAINT transaction_utilisateur_fk FOREIGN KEY (pseudo_utilisateur)
        REFERENCES Utilisateur(pseudo)
);

CREATE TABLE Gestionnaire (
    date_debut TIMESTAMP PRIMARY KEY,
    commission INTEGER NOT NULL CHECK (commission >= 0),
    depense_salariale INTEGER NOT NULL CHECK (depense_salariale >= 0),
    depense_prospect INTEGER NOT NULL CHECK (depense_prospect >= 0)
);

CREATE TABLE Objectif (
    id_objectif SERIAL PRIMARY KEY,
    montant INTEGER NOT NULL,
    titre VARCHAR(50) NOT NULL,
    descri TEXT NOT NULL,
    id_projet INTEGER NOT NULL,
    CONSTRAINT projet_objectif FOREIGN KEY (id_projet)
        REFERENCES Projet(id_projet)
);

CREATE TABLE Categorie( -- Categorie de donnateur
    id SERIAL PRIMARY KEY,
    id_projet INTEGER NOT NULL,
    montant INTEGER NOT NULL CHECK (montant > 0),
    pret VARCHAR(255) NOT NULL, --ce qu'obtient l'utilisateur si il fait un dont superieur au montant
    CONSTRAINT categorie_projet_fk FOREIGN KEY (id_projet)
                      REFERENCES Projet(id_projet)

);

CREATE TABLE Message_Utilisateur (
    id_message SERIAL PRIMARY KEY,
    type INTEGER NOT NULL CHECK ( type > 0 ),
    receveur VARCHAR(255) NOT NULL,
    date_envoi TIMESTAMP NOT NULL ,
    titre VARCHAR(255) NOT NULL ,
    message text NOT NULL,

    CONSTRAINT Message_Utilisateur_fk FOREIGN KEY (receveur)
        REFERENCES Utilisateur(pseudo)
);

CREATE TABLE Message_Beneficiaire  (
    id_message SERIAL PRIMARY KEY,
    type INTEGER NOT NULL,
    receveur VARCHAR(255) NOT NULL,
    date_envoi TIMESTAMP NOT NULL ,
    titre VARCHAR(255) NOT NULL ,
    message text NOT NULL,

    CONSTRAINT Message_Beneficiaire_fk
    FOREIGN KEY (receveur) REFERENCES Beneficiaire(pseudo)
);

CREATE TABLE Prospect (
    email VARCHAR(255) PRIMARY KEY
);