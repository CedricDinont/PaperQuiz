<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');
        require_once('view_files_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
        doFileOperation();
?>
<html>
<head>
	<title>Visualisation des fichiers liés à la reconnaissance des marques</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>

<form method="POST" action="view_omr_files.php?quiz-id=<?php echo $quiz->getId(); ?>" name="file_operations_form">

<h1>Fichiers du répertoire d'entrée</h1>
<ul>
<?php showDirFiles($quiz->getOmrInputDir()) ?>
</ul>

<h1>Fichiers du répertoire de sortie</h1>
<ul>
<?php showDirFiles($quiz->getOmrOutputDir()) ?>
</ul>

<h1>Fichiers du répertoire d'erreur</h1>
<ul>
<?php showDirFiles($quiz->getOmrErrorDir()) ?>
</ul>

<h1>Autres fichiers</h1>
<ul>
<?php showFile("./", "omr.log"); ?>
</ul>
<br><br>

<?php doFilesMenu(); ?>
</form>
<br><br>
<br>
<?php  doMainMenu() ?>
</body>
</html>