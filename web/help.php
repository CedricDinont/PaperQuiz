<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

if (isset($_GET['quiz-id'])) {
        $quiz = Quiz::getQuizById($_GET['quiz-id']);
  }
?>
<html>
<head>
        <title>Aide</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<h1>Description générale de l'application</h1>

Quiz permet de corriger des QCM réalisés sur papier.
La feuille de réponses permet de créer des quiz contenant jusqu'à 80 questions avec chacune au maximum 5 réponses possibles.

<br><br>
<h1>Création et paramétrage d'un quiz</h1>


<br><br>
<h1>Correction d'un quiz</h1>

Il faut tout d'abord scanner les feuilles de réponse.
Pour cela, il faut utiliser la photocopieuse de la salle
de repro au niveau 4.
Se positionner en mode scanner. Il n'y a pas besoin de numéro de compte
pour pouvoir scanner. Paramétrer le scanner comme ceci :
<ul>
<li>Résolution : 200dpi</li>
<li>Couleurs : niveaux de gris</li>
<li>Format des fichiers de sortie : JPEG</li>
<li>Adresse mail : qcm.isen@gmail.com</li>
</ul>
  Utiliser le chargeur au dessus de la photocopieuse. Placer les feuilles avec la face imprimée au dessus dans le sens de lecture (la grosse marque noire en haut à gauche).
<br>
Il ne faut pas scanner plus de 25 feuilles à la fois pour ne pas dépasser
la limite de taille des mails.



<br><br>
<h1>Bugs connus de l'interface Web</h1>
<ul>
<li>Par moments, lorsqu'on visualise la sortie d'un programme, une erreur s'affiche indiquant que des fichiers ne peuvent être ouverts. Il suffit de recharger la page pour que tout rentre dans l'ordre.</li>
<li>Dans la page de correction des erreurs de reconnaissance des marques, le système de déplacement simultané des deux ascenceurs ne fonctionne pas bien.</li>
<li>Si on tente de corriger un quiz n'ayant pas de fichier de correction, le serveur peut partir dans une boucle infinie qui accapare petit à petit toute la mémoire.</li>
</ul>
<br><br>
<h1>Améliorations prévues de l'interface Web</h1>
<ul>
<li>Dans la page de création d'un quiz : mettre un sélecteur de date en JavaScript.</li>
<li>Utiliser de l'Ajax dans la page qui affiche les sorties des processus pour que ce soit plus fluide.</li>
<li>Classement des quiz dans différentes catégories pour pouvoir les retrouver plus facilement.</li>
<li>Classement des processus d'un quiz dans l'ordre chronologique.</li>
<li>Préparer ou modifier un corrigé en ligne.</li>
<li>Dans la page de correction des erreurs de reconnaissance des marques, permettre le déplacement de l'image par glisser-déposer plutôt que de forcer à utiliser les ascenseurs.</li>
</ul>

<?php  doMainMenu() ?>

</body>
</html>
