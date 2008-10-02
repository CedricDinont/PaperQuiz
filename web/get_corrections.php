<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Accès aux fichiers de résultats</title>
</head>
<body>

<br>
<?php  doMainMenu() ?>
</body>
</html>