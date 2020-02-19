SELECT creationtransaction(10, 2, 'siran', FALSE);
SELECT * FROM transaction WHERE pseudo_utilisateur = 'siran';
SELECT creationProjet('Tour du monde', 'je veux de largent pour faire le tour du monde', gettemps() + interval '20 day', 90, 'concert', 'lamar');
SELECT * FROM Projet WHERE pseudo_beneficiaire = 'lamar';