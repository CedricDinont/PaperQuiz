<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Quiz workflow</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
Que voulez-vous faire sur le quiz 
<?php
	echo $quiz->getName();
?> ?

<ul>

<li>Quiz
<ul>
<li>
<a href="configure_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Configurer le quiz</a>
</li>
<li>
<a href="rename_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Renommer le quiz</a>
</li>
<li>
<a href="remove_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Supprimer le quiz</a>
</li>
</ul>
</li>
<br />

<li>Reconnaissance des marques
<ul>
<li>
Récupérer les images scannées <a href="fetch_mails.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">sur le mail qcm.isen@gmail.com</a> / <a href="get_ftp_files.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">sur le FTP de dev.isen.fr</a>
</li>
<li>
Traitements sur les images scannées
<ul>
	<li>
		<a href="correct_images_rotation.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Corriger la rotation des images</a> / <a href="omr.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Lancer la reconnaissance des marques</a>
	</li>
	<li>
		<a href="rotate_and_omr.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Corriger la rotation et reconnaître les marques en une seule étape</a>
	</li>
</ul>
</li>
<li>
<a href="correct_omr_errors.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Corriger les erreurs de reconnaissance</a>
</li>
</ul>
</li>
<br />

<li>Correction
<ul>
<li>
<a href="prepare_correction.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Préparer la correction</a>
</li>
<!-- <li>
 <a href="">Corriger les erreurs de préparation de la correction</a>
</li> -->
<li>
<a href="upload_marking.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Déposer un corrigé</a> 
</li>
<!--  <li>
<a href="modify_marking.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Préparer ou modifier un corrigé en ligne</a> 
</li> -->
<li>Fichier d'informations sur les étudiants
<ul>
<li>
<a href="create_students_file_from_scans_infos.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Générer le fichier d'informations sur les étudiants à partir des pages scannées</a>
</li>
<li>
<a href="select_standard_students_file.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Choisir un fichier d'informations sur les étudiants standard</a>
</li>
</ul>
</li>
<li>
<a href="correct_quiz.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Corriger l'épreuve</a>
</li>
<!-- <li>
<a href="">Associer un fichier FreeMind à une matière</a>
</li> -->
</ul>
</li>
<br />

<li>Processus
<ul>
<li>
<a href="view_process_progress.php?quiz-id=<?php echo $quiz->getId() ?>">Voir la progression du processus courant</a>
</li>
<li>
<a href="view_processes.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Voir les processus terminés</a>
</li>
</ul>
</li>
<br />

<li>Fichiers
<ul>
<li>
<a href="view_omr_files.php?quiz-id=<?php echo $quiz->getId() ?>">Voir les fichiers liés à la reconnaissance des marques</a>
</li>
<li>
<a href="view_correction_files.php?quiz-id=<?php echo $quiz->getId() ?>">Voir les fichiers liés à la correction</a>
</li>
<li>
<a href="get_corrections.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">Récupérer les fichiers OpenOffice avec les résultats</a>
</li>
</ul>
</li>

</ul>



<br>
<?php  doMainMenu() ?>
</body>
</html>
