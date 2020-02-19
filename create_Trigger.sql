DROP TRIGGER IF EXISTS trigger_check_bien_rembourer ON Projet;
DROP TRIGGER IF EXISTS check_solde_uti ON Transaction;
DROP TRIGGER IF EXISTS envoie_message ON Transaction;
DROP TRIGGER IF EXISTS change_temps ON Temps;
DROP TRIGGER IF EXISTS envoie_email_p ON Prospect;
DROP TRIGGER IF EXISTS ajout_objectif_de_base ON projet;

DROP FUNCTION IF EXISTS getTemps();
DROP FUNCTION IF EXISTS creationUtilisateur(pseudo VARCHAR, nom VARCHAR, prenom VARCHAR, mdp VARCHAR);
DROP FUNCTION IF EXISTS creationBeneficiaire(pseudo VARCHAR, nom VARCHAR, prenom VARCHAR, mdp VARCHAR, nom_de_scene VARCHAR, descri TEXT);
DROP FUNCTION IF EXISTS creationProjet(titre VARCHAR, descri TEXT, date_fin TIMESTAMP, montant INTEGER, type_de_projet VARCHAR, pseudo_benef VARCHAR);
DROP FUNCTION IF EXISTS creationGestionnaire(commission INTEGER, depense_salariale INTEGER, depense_prospect INTEGER);
DROP FUNCTION IF EXISTS creationTransaction(mont INTEGER, id_proj INTEGER, pseudo_utilisateur VARCHAR);
DROP FUNCTION IF EXISTS creationCategorie(id_projet INTEGER, montant INTEGER, pret VARCHAR);
DROP FUNCTION IF EXISTS creationObjectif(montant INTEGER, titre VARCHAR, descri TEXT, id_projet INTEGER);
DROP FUNCTION IF EXISTS creationMessageUtilisateur(type INTEGER, receveur VARCHAR, titre VARCHAR, message text);
DROP FUNCTION IF EXISTS creationMessageBeneficiaire(type INTEGER, receveur VARCHAR, titre VARCHAR, message text);
DROP FUNCTION IF EXISTS creationProspect(email VARCHAR);
DROP FUNCTION IF EXISTS addOneDay();
DROP FUNCTION IF EXISTS addOneWeek();
DROP FUNCTION IF EXISTS addOneMonth();
DROP FUNCTION IF EXISTS rembourserPret(id_proj INTEGER, pseudo_uti VARCHAR);
DROP FUNCTION IF EXISTS check_pret_rembourser();
DROP FUNCTION IF EXISTS check_solde_utilisateur();
DROP FUNCTION IF EXISTS envoie_message();
DROP FUNCTION IF EXISTS envoie_message_critique();
DROP FUNCTION IF EXISTS cloture_projet();
DROP FUNCTION IF EXISTS associer_fonction_temps();
DROP FUNCTION IF EXISTS envoie_mail_prospect();
DROP FUNCTION IF EXISTS rentable();
DROP FUNCTION IF EXISTS objectif(idP INTEGER);
DROP FUNCTION IF EXISTS ajout_obj();

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION getTemps() RETURNS TIMESTAMP AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM Temps) = 0 THEN
        INSERT INTO Temps(date_actuelle) VALUES (CURRENT_DATE);
    END IF;
    RETURN (SELECT date_actuelle FROM Temps LIMIT 1);
END;
$$ LANGUAGE plpgsql;


/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationUtilisateur(pseudo VARCHAR(50), nom VARCHAR(255), prenom VARCHAR(255),
                                               mdp VARCHAR(50)) RETURNS void AS
$$
BEGIN
    IF pseudo IS NULL OR pseudo = '' THEN
        RAISE EXCEPTION 'Pseudo is null';
    ELSIF nom IS NULL OR nom = '' THEN
        RAISE EXCEPTION 'Name is null';
    ELSIF prenom IS NULL OR prenom = '' THEN
        RAISE EXCEPTION 'Prenom is null';
    ELSIF mdp IS NULL OR mdp = '' THEN
        RAISE EXCEPTION 'Password is null';
    ELSE
        INSERT INTO Utilisateur(pseudo, nom, prenom, mdp, solde) VALUES (pseudo, nom, prenom, mdp, 100);
    END IF;
END
$$ LANGUAGE plpgsql;


/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationBeneficiaire(pseudo VARCHAR(50), nom VARCHAR(255), prenom VARCHAR(255),
                                                mdp VARCHAR(50), nom_de_scene VARCHAR(255), descri TEXT) RETURNS void AS
$$
BEGIN
    IF pseudo IS NULL OR pseudo = '' THEN
        RAISE EXCEPTION 'Pseudo is null';
    ELSIF nom IS NULL OR nom = '' THEN
        RAISE EXCEPTION 'Name is null';
    ELSIF prenom IS NULL OR prenom = '' THEN
        RAISE EXCEPTION 'Prenom is null';
    ELSIF mdp IS NULL OR mdp = '' THEN
        RAISE EXCEPTION 'Password is null';
    ELSIF nom_de_scene IS NULL OR nom_de_scene = '' THEN
        RAISE EXCEPTION 'Nom de scene is null';
    ELSE
        INSERT INTO Beneficiaire(pseudo, nom, prenom, mdp, nom_de_scene, descri)
        VALUES (pseudo, nom, prenom, mdp, nom_de_scene, descri);
    END IF;
END
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationProjet(titre VARCHAR(50), descri TEXT, date_fin TIMESTAMP, montant INTEGER,
                                          type_de_projet VARCHAR(255), pseudo_benef VARCHAR(50)) RETURNS void AS
$$
BEGIN
    IF titre IS NULL OR titre = '' THEN
        RAISE EXCEPTION 'Titre is null';
    ELSIF descri IS NULL THEN
        RAISE EXCEPTION 'Description is null';
    ELSIF date_fin IS NULL OR date_fin <= getTemps() THEN
        RAISE EXCEPTION 'Date de fin is valid';
    ELSIF montant IS NULL THEN
        RAISE EXCEPTION 'Montant is null';
    ELSIF type_de_projet IS NULL OR type_de_projet = '' THEN
        RAISE EXCEPTION 'Type de projet is null';
    ELSIF pseudo_benef IS NULL OR pseudo_benef = '' THEN
        RAISE EXCEPTION 'Pseudo beneficaire is null';
    ELSE
        INSERT INTO Projet(titre, descri, date_fin, montant_atteindre, type_de_projet, pseudo_beneficiaire)
        VALUES (titre, descri, date_fin, montant, type_de_projet, pseudo_benef);
    END IF;
END
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationGestionnaire(commission INTEGER, depense_salariale INTEGER,
                                                depense_prospect INTEGER) RETURNS void AS
$$
begin
    IF commission IS NULL OR commission = 0 THEN
        RAISE EXCEPTION 'Commsission is null';
    ELSIF depense_salariale IS NULL THEN
        RAISE EXCEPTION 'Depense salaire is null';
    ELSIF depense_prospect IS NULL THEN
        RAISE EXCEPTION 'Depense prospect is null';
    ELSE
        INSERT INTO Gestionnaire(date_debut, commission, depense_salariale, depense_prospect)
        VALUES (getTemps(), commission, depense_salariale, depense_prospect);
    END IF;

end;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationTransaction(mont INTEGER, id_proj INTEGER, pseudo_utilisateur VARCHAR(50),
                                               type_d BOOLEAN) RETURNS void AS
$$
DECLARE
    com    INTEGER;
    stat   INTEGER;
    pret_r BOOLEAN;
BEGIN
    IF mont IS NULL THEN
        RAISE EXCEPTION 'Montant is null';
    ELSIF id_proj IS NULL THEN
        RAISE EXCEPTION 'Id project is null';
    ELSIF pseudo_utilisateur IS NULL THEN
        RAISE EXCEPTION 'Pseudo utilisateur is null';
    ELSIF type_d IS NULL THEN
        RAISE EXCEPTION 'Type don is null';
    ELSE
        IF type_d = TRUE THEN
            stat = 0;
        ELSE
            stat = 1;
        end if;
        IF (SELECT COUNT(*) FROM categorie WHERE id_proj = categorie.id_projet AND mont >= categorie.montant) =
           0 THEN
            pret_r = TRUE;
        ELSE
            pret_r = FALSE;
        end if;
        SELECT commission FROM Gestionnaire ORDER BY date_debut DESC LIMIT 1 INTO com;
        INSERT INTO Transaction(montant, frais_de_gestion, id_projet, pseudo_utilisateur, date_transaction,
                                pret_rembourse, statut, type_don)
        VALUES ((mont * (1 - (com::float) / 100)::float), (mont * com::float / 100), id_proj,
                pseudo_utilisateur, getTemps(), pret_r, stat, type_d);
    END IF;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationCategorie(id_projet INTEGER, montant INTEGER, pret VARCHAR(255)) RETURNS void AS
$$
BEGIN
    IF id_projet IS NULL THEN
        RAISE EXCEPTION 'Id projet is null';
    ELSIF montant IS NULL THEN
        RAISE EXCEPTION 'Montant is null';
    ELSIF pret IS NULL OR pret = '' THEN
        RAISE EXCEPTION 'Pret is null';
    ELSE
        INSERT INTO Categorie(id_projet, montant, pret) VALUES (id_projet, montant, pret);
    END IF;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationObjectif(montant INTEGER, titre VARCHAR(255), descri TEXT, id_projet INTEGER) RETURNS void AS
$$
BEGIN
    IF id_projet IS NULL THEN
        RAISE EXCEPTION 'Id projet is null';
    ELSIF montant IS NULL THEN
        RAISE EXCEPTION 'Montant is null';
    ELSIF titre IS NULL OR titre = '' THEN
        RAISE EXCEPTION 'Pret is null';
    ELSIF descri IS NULL OR descri = '' THEN
        RAISE EXCEPTION 'Pret is null';
    ELSE
        INSERT INTO Objectif(montant, titre, descri, id_projet) VALUES (montant, titre, descri, id_projet);
    END IF;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationMessageUtilisateur(type INTEGER, receveur VARCHAR(255), titre VARCHAR(255),
                                                      message text) RETURNS void AS
$$
BEGIN
    IF type IS NULL THEN
        RAISE EXCEPTION 'Type is null';
    ELSIF receveur IS NULL OR receveur = '' THEN
        RAISE EXCEPTION 'receveur is null';
    ELSIF titre IS NULL OR titre = '' THEN
        RAISE EXCEPTION 'titre is null';
    ELSIF message IS NULL OR message = '' THEN
        RAISE EXCEPTION 'message is null';
    ELSE
        INSERT INTO Message_Utilisateur(type, receveur, date_envoi, titre, message)
        VALUES (type, receveur, getTemps(), titre, message);
    END IF;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationMessageBeneficiaire(type INTEGER, receveur VARCHAR(255), titre VARCHAR(255),
                                                       message text) RETURNS void AS
$$
BEGIN
    IF type IS NULL THEN
        RAISE EXCEPTION 'Type is null';
    ELSIF receveur IS NULL OR receveur = '' THEN
        RAISE EXCEPTION 'receveur is null';
    ELSIF titre IS NULL OR titre = '' THEN
        RAISE EXCEPTION 'titre is null';
    ELSIF message IS NULL OR message = '' THEN
        RAISE EXCEPTION 'message is null';

    ELSE
        INSERT INTO Message_Beneficiaire(type, receveur, date_envoi, titre, message)
        VALUES (type, receveur, getTemps(), titre, message);
    END IF;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION creationProspect(email VARCHAR(255)) RETURNS void AS
$$
BEGIN
    IF email IS NULL OR email = '' THEN
        RAISE EXCEPTION 'Email is null';
    ELSE
        INSERT INTO Prospect(email) VALUES (email);
    end if;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION inviterUtilisateur(pseudo_uti VARCHAR(50), idProjet INTEGER) RETURNS void AS
$$
DECLARE
    pseudo_benef VARCHAR(50);
    titr         VARCHAR(255);
BEGIN
    SELECT Projet.titre, pseudo_beneficiaire FROM projet WHERE id_projet = idProjet INTO titr, pseudo_benef;
    PERFORM creationMessageUtilisateur(3, pseudo_uti, 'Invitation sur un projet',
                                      pseudo_uti || ' vous a invite a faire un don pour le projet ' || titr ||
                                      ' creer par ' || pseudo_benef);
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION addOneDay() RETURNS void AS
$$
BEGIN
    UPDATE Temps SET date_actuelle = getTemps() + INTERVAL ' 1 day' WHERE date_actuelle = getTemps();
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION addOneWeek() RETURNS void AS
$$
BEGIN
    UPDATE Temps SET date_actuelle = getTemps() + INTERVAL ' 1 week' WHERE date_actuelle = getTemps();
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION addOneMonth() RETURNS void AS
$$
BEGIN
    UPDATE Temps SET date_actuelle = getTemps() + INTERVAL ' 1 month' WHERE date_actuelle = getTemps();
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION rembourserPret(id_proj INTEGER, pseudo_uti VARCHAR(50)) RETURNS void AS
$$
BEGIN
    UPDATE Transaction SET pret_rembourse = TRUE WHERE id_projet = id_proj AND pseudo_utilisateur = pseudo_uti;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION rentable() RETURNS BOOLEAN AS
$$
DECLARE
    depense_s INTEGER;
    depense_p INTEGER;
BEGIN
    SELECT depense_salariale, depense_prospect
    FROM gestionnaire
    ORDER BY date_debut DESC
    LIMIT 1 INTO depense_s, depense_p;
    IF depense_p + depense_s < (SELECT SUM(frais_de_gestion) FROM transaction WHERE statut = 1) THEN
        RETURN TRUE;
    end if;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;



/*********************************************************************************************************************************/
-- TRIGGERS PROJET
/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION check_pret_rembourser() RETURNS TRIGGER AS
$$
DECLARE
    res INTEGER;
    pret BOOLEAN;
BEGIN
    FOR res IN SELECT id_projet FROM Projet WHERE NEW.pseudo_beneficiaire = pseudo_beneficiaire
        LOOP
            FOR pret IN SELECT pret_rembourse
                FROM Transaction
                WHERE id_projet = res
            LOOP
                IF pret = FALSE THEN
                    RAISE EXCEPTION 'Pret pas rembourser dans precedent projet';
                end if;
            end loop;
        end loop;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION ajout_obj() RETURNS TRIGGER AS $$
    BEGIN
        PERFORM creationobjectif(NEW.montant_atteindre, NEW.titre, NEW.descri, NEW.id_projet);
        RETURN NEW;
    end;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE TRIGGER trigger_check_bien_rembourer
    BEFORE INSERT
    ON Projet
    FOR EACH ROW
EXECUTE PROCEDURE check_pret_rembourser();

/*********************************************************************************************************************************/

CREATE TRIGGER ajout_objectif_de_base
    AFTER INSERT
    ON Projet
    FOR EACH ROW
    EXECUTE PROCEDURE ajout_obj();



/*********************************************************************************************************************************/
--TRIGGER TRANSCTION
/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION check_solde_utilisateur() RETURNS TRIGGER AS
$BODY$
DECLARE
    sold INTEGER;
BEGIN
    SELECT solde FROM utilisateur WHERE NEW.pseudo_utilisateur = pseudo INTO sold;
    IF 100 < (SELECT SUM(montant) + SUM(frais_de_gestion)
              FROM transaction
              WHERE pseudo_utilisateur = NEW.pseudo_utilisateur) + NEW.montant THEN
        RAISE EXCEPTION 'Le solde de lutilisateur est insuffisant';
    ELSIF NEW.statut = 1 THEN
        UPDATE utilisateur
        SET solde = (sold - NEW.montant - NEW.frais_de_gestion)
        WHERE pseudo = NEW.pseudo_utilisateur;
    end if;
    RETURN NEW;
END;
$BODY$ LANGUAGE 'plpgsql';

/*********************************************************************************************************************************/

CREATE TRIGGER check_solde_uti
    BEFORE INSERT
    ON Transaction
    FOR EACH ROW
EXECUTE PROCEDURE check_solde_utilisateur();

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION objectif(idP INTEGER) RETURNS void AS $$
    DECLARE nouvelle_obj INTEGER;
        nouveau_titre VARCHAR(255);
        nouvel_descri text;
        somme FLOAT;
    BEGIN
        SELECT SUM(montant) FROM transaction WHERE id_projet = idP INTO somme;
        IF ( (SELECT COUNT(*) FROM objectif WHERE id_projet = idP AND  montant > somme) > 0 ) AND (somme) > (SELECT montant_atteindre FROM projet WHERE id_projet = idP) THEN
            SELECT montant, titre, descri FROM objectif WHERE id_projet = idP AND  montant > somme ORDER BY montant ASC LIMIT 1 INTO nouvelle_obj, nouveau_titre, nouvel_descri;
            UPDATE projet SET montant_atteindre = nouvelle_obj, titre = nouveau_titre, descri = nouvel_descri WHERE id_projet = idP;
        end if;
    end;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE Function envoie_message() RETURNS TRIGGER AS
$$
DECLARE
    com      INTEGER;
    receveur VARCHAR(50);
BEGIN
    SELECT pseudo_beneficiaire FROM projet WHERE new.id_projet = projet.id_projet INTO receveur;
    PERFORM creationMessageBeneficiaire(1, receveur, 'nouveau donnateur',
                                        text(new.pseudo_utilisateur || ' vous a fait un don de ' || new.montant ||
                                             ' pour votre projet '));
    SELECT commission FROM Gestionnaire ORDER BY date_debut DESC LIMIT 1 INTO com;
    PERFORM creationMessageUtilisateur(1, new.pseudo_utilisateur, 'nouveau don utilisateur',
                                       text('don effectue au projet ' || new.montant ||
                                            ' frais de gestion ' || new.frais_de_gestion));
    PERFORM objectif(new.id_projet);
    RETURN new;
END ;
$$ language plpgsql;

/*********************************************************************************************************************************/

CREATE TRIGGER envoie_message
    AFTER INSERT
    ON Transaction
    FOR EACH ROW
EXECUTE PROCEDURE envoie_message();



/*********************************************************************************************************************************/
--TRIGGER TEMPS
/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION envoie_message_critique()
    RETURNS void AS
$$
DECLARE
    proj  Projet%rowtype;
    pseud VARCHAR(50);
BEGIN
    FOR proj in SELECT *
                FROM projet
                WHERE date_fin = getTemps() + INTERVAL '2 day'
                  AND ((SELECT SUM(montant) FROM Transaction WHERE transaction.id_projet = projet.id_projet) <
                       projet.montant_atteindre::float / 2 OR
                       (SELECT COUNT(*) FROM Transaction WHERE transaction.id_projet = projet.id_projet) = 0)
        LOOP
            for pseud IN SELECT pseudo
                         from utilisateur
                         WHERE pseudo NOT IN
                               (SELECT pseudo_utilisateur FROM transaction where id_projet = proj.id_projet)
                LOOP
                    PERFORM creationMessageUtilisateur(2, pseud, 'donnation urgente',
                                                       text('le projet ' || proj.titre ||
                                                            ' se termine dans 2 jours et na pas atteint la moitie de
                                                            son objectif faite un don sil vous plait'));
                end loop;
        end loop;
end ;
$$ language plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION cloture_projet() RETURNS void AS
$$
DECLARE
    id_p INTEGER;
BEGIN
    FOR id_p IN SELECT id_projet,
                             montant_atteindre
                      FROM projet
                      WHERE date_fin = getTemps()
        LOOP
            IF (SELECT SUM(montant)
                FROM transaction
                WHERE id_projet = id_p) > (SELECT montant FROM objectif WHERE id_projet = id_p ORDER BY montant LIMIT 1) THEN
                WITH tr
                         AS (UPDATE transaction SET statut = 1 WHERE id_projet = id_p AND type_don = TRUE RETURNING pseudo_utilisateur, montant)
                UPDATE utilisateur
                SET solde = solde - tr.montant
                FROM tr
                WHERE pseudo = tr.pseudo_utilisateur;
            ELSE
                WITH tr
                         AS (UPDATE transaction SET statut = 2, pret_rembourse = TRUE WHERE id_projet = id_p AND type_don = FALSE RETURNING pseudo_utilisateur, montant)
                UPDATE utilisateur
                SET solde = solde + tr.montant
                FROM tr
                WHERE pseudo = tr.pseudo_utilisateur;
            end if;
        end loop;
end;
$$ LANGUAGE plpgsql;

/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION associer_fonction_temps() RETURNS TRIGGER AS
$$
BEGIN
    PERFORM envoie_message_critique();
    PERFORM cloture_projet();
    RETURN NEW;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER change_temps
    AFTER UPDATE
    ON temps
    FOR EACH ROW
EXECUTE PROCEDURE associer_fonction_temps();



/*********************************************************************************************************************************/
--TRIGGER PROSPECT
/*********************************************************************************************************************************/

CREATE OR REPLACE FUNCTION envoie_mail_prospect() RETURNS TRIGGER AS
$$

BEGIN
    --envoie de mail sur new.email
    RAISE LOG 'envoie de mail aux prospect dont ladresse est %', NEW.email;
    RETURN NEW;
end ;


$$ language plpgsql;

/*********************************************************************************************************************************/

CREATE TRIGGER envoie_email_p
    AFTER INSERT
    ON prospect
    FOR EACH ROW
execute procedure envoie_mail_prospect();
