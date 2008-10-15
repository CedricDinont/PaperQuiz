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
<a href="configure_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Configurer le quiz</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="fetch_mails.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Récupérer les images scannées sur le mail qcm.isen@gmail.com</a>
</li>
<li>
<a href="omr.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Lancer la reconnaissances des marques</a>
</li>
<li>
<a href="">Corriger les erreurs de reconnaissance</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="prepare_correction.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Préparer la correction</a>
</li>
<li>
<a href="">Corriger les erreurs de préparation de la correction</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="modify_marking.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Préparer ou modifier un corrigé</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="create_students_file_from_scans_infos.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Générer le fichier d'informations sur les étudiants à partir des pages scannées</a>
</li>
<li>
<a href="chosse_standard_students_file.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Choisir un fichier d'informations sur les étudiants standard</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="correct_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Corriger l'épreuve</a>
</li>
<li>
<a href="get_corrections.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Récupérer les fichiers OpenOffice avec les résultats</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="">Associer un fichier FreeMind à une matière</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="rename_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Renommer le quiz</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="remove_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Supprimer le quiz</a>
</li>
<li>
<a href="view_processes.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Voir les processus terminés</a>
</li>
<li>
<a href="view_process_progress.php?quiz-id=<?php echo $quiz->getId() ?>">Voir la progression du processus courant</a>
</li>
<li>
<a href="view_omr_files.php?quiz-id=<?php echo $quiz->getId() ?>">Voir les fichiers liés à la reconnaissance des marques</a> (Fonctionnalité pas encore disponible)
</li>
<li>
<a href="view_correction_files.php?quiz-id=<?php echo $quiz->getId() ?>">Voir les fichiers liés à la correction</a> (Fonctionnalité pas encore disponible)
</li>
</ul>
<br>
<?php  doMainMenu() ?>
</body>
</html>
