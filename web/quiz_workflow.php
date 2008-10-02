<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Quiz workflow</title>
</head>
<body>
Que voulez-vous faire sur le quiz 
<?php
	echo $quiz->getName();
?> ?
<ul>
<li>
<a href="">Configurer le quiz</a>
</li>
<li>
<a href="fetch_mails.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Récupérer les images scannées sur le mail qcm.isen@gmail.com</a>
</li>
<li>
<a href="omr.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Lancer la reconnaissances des marques</a>
</li>
<li>
<a href="">Corriger les erreurs de reconnaissance</a>
</li>
<li>
<a href="">Préparer la correction</a>
</li>
<li>
<a href="">Corriger les erreurs de préparation de la correction</a>
</li>

<li>
<a href="">Préparer ou modifier un corrigé</a>
</li>
<li>
<a href="">Corriger l'épreuve</a>
</li>
<li>
<a href="">Récupérer le fichier OpenOffice avec les résultats</a>
</li>
<li>
<a href="">Associer un fichier FreeMind à une matière</a>
</li>
<li>
<a href="">Renommer le quiz</a>
</li>
<li>
<a href="">Supprimer le quiz</a>
</li>
</li>
<li>
<a href="view_processes.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Visualiser les processus terminés</a>
</li>
<li>
<a href="view_process_progress.php?quiz-id=<?php echo $quiz->getId() ?>">Voir la progression du processus courant</a>
</li>
</ul>

<?php  doMainMenu() ?>
</body>

