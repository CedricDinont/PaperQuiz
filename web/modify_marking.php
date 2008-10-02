<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Préparation / modification d'un corrigé</title>
</head>
<body>

<br>
<?php  doMainMenu() ?>
</body>
</html>