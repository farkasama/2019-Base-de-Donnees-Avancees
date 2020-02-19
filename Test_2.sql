SELECT creationtransaction(20, 3, 'jurs', FALSE);
SELECT * FROM Transaction WHERE pseudo_utilisateur = 'jurs';
SELECT creationProjet('Financement resto du coeur', 'on veut de largent pour les resto du coeur', gettemps()+INTERVAL '15 days', 70, 'caritatif', 'jjg');
SELECT rembourserpret(3, 'jurs');
SELECT creationProjet('Financement resto du coeur', 'on veut de largent pour les resto du coeur', gettemps()+INTERVAL '15 days', 70, 'caritatif', 'jjg');
SELECT * FROM Projet WHERE pseudo_beneficiaire = 'jjg';