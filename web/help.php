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
Il est possible de poser des questions pour plusieurs matières avec une seule feuille de réponses.
Les feuilles de réponses sont scannées puis traitées par plusieurs programmes d'OMR (Optical Mark Recognition). Les données produites sont corrigées et les résultats
 sont fournis dans un fichier Open Office par matière.<br><br>
Cette page décrit les fonctionnalités disponibles dans cette interface Web en ne décrivant que ce qui est nécessaire du fonctionnement interne de l'application.
<br><br>
<h1>Création et paramétrage d'un quiz</h1>
La page d'accueil du site permet de créer un nouveau quiz ou d'accéder aux informations concernant un quiz existant.<br><br>
Pour créer un quiz, il faut renseigner les informations suivantes :
<ul>
<li>la date à laquelle les étudiants font le quiz,</li>
<li>le nom du groupe d'étudiants concerné,</li>
<li>le nom donné au quiz.</li>
</ul>
Procéder ainsi permet de retrouver facilement un ancien quiz. Les fichiers de chaque quiz sont sauvegardés sur le serveur dans un répertoire dont le nom est celui du quiz.
<br>
<br>
  Une fois le quiz créé, on peut le paramétrer. Sélectionner le quiz à configurer dans la page d'accueil puis cliquer sur "Go". La page avec les différents traitements possibles sur le quiz s'affiche.<br><br>
  La première chose à faire est de configurer le nombre de questions pour chaque matière. Pour cela, cliquer sur "Configurer le quiz".
Dans la page qui s'affiche, entrer le nom de chaque matière ainsi que les numéros des questions de début et de fin de chaque matière sur la feuille de réponses.
Après validation, la configuration est mémorisée dans le fichier quiz.conf du répertoire du quiz.<br><br>
Ensuite, il est possible de déposer les corrigés pour les différentes matières configurées précédemment. Pour cela, cliquer sur "Déposer un corrigé". Sélectionner sur votre disque les fichiers à envoyer. Chaque matière doit avoir son propre fichier de correction, qui doit respecter <a href="marking_file_format.php">un format particulier</a>. Il est possible d'envoyer un ou plusieurs fichiers à la fois. Les fichiers sont renommés ainsi sur le serveur : "nom_matière.marking".
<br>
<br>
  La dernière étape de la configuration consiste à créer le fichier donnant les informations sur les étudiants concernés par le quiz. Ce fichier donne la correspondance entre les logins et les noms des étudiants. Il existe deux manières de réaliser cela :
<ul>
  <li>Sélectionner un fichier standard qui sera copié dans le répertoire du quiz. Cette méthode a l'avantage de pouvoir gérer les absents : ceux-ci seront indiqués dans le fichier Open Office de résultats.</li>
  <li>Créer le fichier à partir des feuilles de réponses scannées. Si on choisit cette méthode, il faut réaliser cette étape pendant la correction du quiz, après avoir réalisé la préparation de la correction. Le fichier est créé en lançant une requête dans l'annuaire LDAP pour chaque login reconnu sur les feuilles de réponses.</li>
</ul>

<br><br>
<h1>Correction d'un quiz</h1>

Il faut tout d'abord scanner les feuilles de réponses.
Pour cela, il faut utiliser la photocopieuse de la salle
de repro au niveau 4.
Se positionner en mode scanner. Il n'y a pas besoin de numéro de compte
pour pouvoir scanner. Paramétrer le scanner comme ceci :
<ul>
<li>Résolution : 200 dpi</li>
<li>Couleurs : niveaux de gris</li>
<li>Format des fichiers de sortie : JPEG</li>
<li>Adresse mail : qcm.isen@gmail.com</li>
</ul>
  Utiliser le chargeur au dessus de la photocopieuse. Placer les feuilles avec la face imprimée au dessus dans le sens de lecture (la grosse marque noire en haut à gauche).
<br>
Il ne faut pas scanner plus de 25 feuilles à la fois pour ne pas dépasser
la limite de taille des mails.

<br>
  Pour les prochaines étapes, il est conseillé de conserver les pages dans l'ordre où elles ont été scannées.

<br><br>
Sélectionner le quiz à corriger dans la page d'accueil puis cliquer sur "Go". La page avec les différents traitements possibles sur le quiz s'affiche.
<br><br>
  Les feuilles scannées ont été envoyées sur le mail qcm.isen@gmail.com. Il faut les rapatrier dans le répertoire d'entrée du processus de reconnaissance des marques en cliquant sur "Récupérer les images scannées sur le mail qcm.isen@gmail.com". La page qui s'affiche permet de suivre l'évolution du processus. Elle se rafraîchit toutes les 5 secondes pour récupérer l'état actuel des sorties standard et d'erreur du script lancé en arrière-plan sur le serveur. L'état du processus ("en cours" ou "terminé") s'affiche en haut de la page. Une fois le processus terminé, la page ne se rafraîchit plus. A tout moment, il est possible de revenir sur la page d'accueil ou la page du quiz courant. Le processus continue à tourner en arrière-plan et on peut revenir à la visualisation de sa progression en cliquant sur "Voir la progression du processus courant" dans la page du quiz. Comme il n'y a aucun moyen d'associer des scans à un quiz au niveau de la photocopieuse, il est conseillé de récupérer les images tout de suite après les avoir scannées pour éviter que quelqu'un d'autre ne scanne des images et qu'elles soient toutes mélangées.
<br><br>
  Une fois qu'on a récupéré les fichiers des pages scannées, on peut lancer le processus de reconnaissance des marques en cliquant sur "Lancer la reconnaissance des marques". Ce processus se lance de la même manière que le précédent. Pour chaque image, plusieurs programmes d'OMR différents tentent de reconnaître les marques. S'ils trouvent exactement les mêmes marques, l'image et les fichiers générés pendant la reconnaissance des marques sont déplacés vers un répertoire de sortie. S'il y a une différence, les fichiers sont placés dans un répertoire d'erreur. Si 3 programmes d'OMR sont utilisés, il suffit que 2 déterminent les mêmes marques pour que l'image soit acceptée.
<br><br>
  La reconnaissance des marques n'est pas un processus fiable à 100%. C'est pourquoi il convient de parcourir l'ensemble des images pour vérifier que la reconnaissance des marques a bien fonctionné. En cliquant sur "Corriger les erreurs de reconnaissance", on accède à une interface qui permet de visualiser les marques détectées sur les scans et éventuellement de les corriger. Par défaut, on visualise les fichiers du répertoire d'erreur. Pour chaque fichier, on peut voir ce qu'a détecté le premier programme d'OMR ou le second. La partie à droite de la fenêtre permet de modifier l'état de chaque case. Les modifications sont prises en compte en cliquant sur "Apply" ou annulées en cliquant sur "Discard". Les images pour lesquelles on a cliqué sur "Apply" sont déplacées dans le répertoire de sortie. Il est important de cliquer sur "Apply" pour chaque image du répertoire d'erreur, même si on n'effectue aucune correction. En effet, les étapes suivantes considèrent uniquement les fichiers présents dans le répertoire de sortie. Après avoir corrigé les images du répertoire d'erreur, IL EST IMPORTANT DE PARCOURIR TOUTES LES IMAGES DU REPERTOIRE DE SORTIE POUR LES VERIFIER. Penser à utiliser le zoom pour ne rater aucune marque.
<br><br>
  Les données de reconnaissance des marques étant corrigées et vérifiées, on peut maintenant corriger le quiz. Cela se fait en deux étapes : la préparation et la correction effective.<br><br>
  La préparation consiste à reconnaître les logins des étudiants en fonction des marques détectées sur les premières lignes puis à séparer les marques en fonction des matières. Cette étape peut faire apparaître des erreurs comme par exemple des marques multiples sur une seule ligne dans la partie login. Dans ce cas, il faut revenir à l'interface de correction des marques pour effectuer la modification nécessaire et relancer le processus de préparation de la correction.
<br>
<br>
La correction effective permet de générer le fichier Open Office final avec le résultat du quiz pour chaque matière configurée. Cette étape a besoin des fichiers de correction, du fichier d'information sur les étudiants et du résultat de l'étape de préparation de la correction. Les fichiers Open Office peuvent être téléchargés à partir de la page principale du quiz. Si le fichier généré comporte des erreurs, il est possible d'effectuer des corrections aux étapes précédentes et de relancer les différents processus jusqu'à la création des fichiers Open Office.
<br><br>
A la fin de la correction, on archive le sujet du quiz avec les feuilles de réponses.

<br><br><br>
<h1>Fonctionnalités supplémentaires de l'interface Web</h1>
<ul>
<li>Il est possible de visualiser les sorties standard et d'erreur de l'ensemble des processus déjà exécutés.</li>
<li>Il est possible d'accéder directement à l'ensemble des fichiers liés à la reconnaissance des marques (images d'entrée, de sortie, fichiers avec les marques reconnues, logs) et à la correction (fichiers de correction, fichiers de réponses des étudiants, fichier d'information sur les étudiants, fichiers .csv intermédiaires et fichiers Open Office finaux).</li>
</ul>

<br><br>
<h1>Bugs connus de l'interface Web</h1>
<ul>
<li>Par moments, lorsqu'on visualise la sortie d'un programme, une erreur s'affiche indiquant que des fichiers ne peuvent être ouverts. Il suffit de recharger la page pour que tout rentre dans l'ordre.</li>
<li>Dans la page de correction des erreurs de reconnaissance des marques, le système de déplacement simultané des deux ascenceurs ne fonctionne pas bien. Le système de zoom ("fit width" et "fit height") ne fonctionne pas bien également.</li>
</ul>
<br><br>
<h1>Améliorations prévues de l'interface Web</h1>
<ul>
<li>Dans la page de création d'un quiz : mettre un sélecteur de date en JavaScript.</li>
<li>Utiliser de l'Ajax dans la page qui affiche les sorties des processus pour que ce soit plus fluide.</li>
<li>Classement des quiz dans différentes catégories pour pouvoir les retrouver plus facilement.</li>
<li>Préparer ou modifier un corrigé en ligne.</li>
<li>Modifier le fichier d'information sur les étudiants en ligne.</li>
<li>Dans la page de correction des erreurs de reconnaissance des marques, permettre le déplacement de l'image par glisser-déposer plutôt que de forcer à utiliser les ascenseurs.</li>
<li>Indiquer les prochaines étapes à réaliser dans la page du workflow d'un quiz.</li>
<li>Permettre de déposer un fichier Open Office de résultats modifié manuellement pour archivage.</li>
</ul>
<br>
<?php  doMainMenu() ?>

</body>
</html>
