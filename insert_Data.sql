--commission, depense salariale, depense prospect
SELECT creationgestionnaire(5, 4, 1);

--pseudo, nom, prenom, mdp
SELECT creationutilisateur('siran', 'Sirangelo', 'Cristina', 'mdp');
SELECT creationutilisateur('lapla', 'Laplante', 'Sophie', 'mdp');
SELECT creationutilisateur('jurs', 'Jurski', 'Yan', 'mdp');
SELECT creationutilisateur('peri', 'Perifel', 'Sylvain', 'mdp');
SELECT creationutilisateur('yunes', 'Yunes', 'Jean-Baptiste', 'mdp');


--pseudo, nom, prenom, mdp, nom de scene, description
SELECT creationbeneficiaire('pnl', 'N.O.S.', 'Ademo', 'mdp', 'PNL', 'On fait du rap et on vient de Corbeil-Essonnes');
SELECT creationbeneficiaire('lamar', 'Lamar', 'Kendrick', 'mdp', 'Kendrick Lamar', 'Je fais du rap US');
SELECT creationbeneficiaire('jjg', 'Goldman', 'Jean-Jacques', 'mdp', 'Jean-Jacques Goldman', 'Je fais de la Pop-Rock');
SELECT creationbeneficiaire('jc', 'Cole', 'J', 'mdp', 'JCole', 'Je fais du rap US');
SELECT creationbeneficiaire('booba', 'Yaffa', 'Ellie', 'mdp', 'Booba', 'Je fais du Rap et je viens de Boulogne');
SELECT creationbeneficiaire('cd', 'Dion', 'Celine', 'mdp', 'Celine Dion', 'Je fais de la Pop Rock et je viens de Montreal au Canada');

--titre, description, dqte de fin, objectif, type, beneficiaire
SELECT creationprojet('Financement clip', 'on veut de largent pour louer la Tour Eiffel pour un clip', gettemps()+ INTERVAL '1 day', 50, 'clip', 'pnl');
SELECT creationprojet('Financement louer une salle', 'je veux louer le Madison Square Garden', gettemps() + interval '1 day', 20, 'salle', 'lamar');
SELECT creationprojet('Financement album', 'je veux faire un nouvel album', gettemps()+INTERVAL '10 day', 15, 'album', 'jjg');
SELECT creationprojet('Financement anniversaire', 'je veux faire un chanter à un anniversaire ', gettemps()+INTERVAL '3 day', 50, 'anniversaire', 'booba');
SELECT creationprojet('Financement showcase', 'Prommouvoir dernier album au Parc des Princes ', gettemps()+INTERVAL '10 day', 20, 'showcase', 'jc');
SELECT creationprojet('Financement paix dans le monde', 'je veux chanter pour la paix dans le monde mon dernier single ', gettemps()+INTERVAL '10 day', 10, 'paix', 'cd');

--objectif, titre, description
SELECT creationobjectif(80, 'Location champs', 'on veut louer les champs-elysees', 1);
SELECT creationobjectif(90, 'Location versailles', 'et aussi le chateau de versailles', 1);

SELECT creationobjectif(40, 'Location Staples Center', 'on veut louer Staples Center', 2);
SELECT creationobjectif(60, 'Location Staples Center', 'on veut louer Staples Center', 2);

SELECT creationobjectif(25, 'Double album', 'un double album', 3);
SELECT creationobjectif(55, 'Location Stade de France', 'on veut louer le stade de france', 3);

--projet, montant, description
SELECT creationcategorie(1, 40, 'Une visite dans les loges de lartiste');

SELECT creationcategorie(2, 30, 'Une place de concert');

SELECT creationcategorie(3, 15, 'Lalbum');

SELECT creationcategorie(4, 12, 'Un tshirt');