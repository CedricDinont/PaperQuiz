<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Visualisation des fichiers liés à la reconnaissance des marques</title>
</head>
<body>

<br>
<?php  doMainMenu() ?>
</body>
</html>