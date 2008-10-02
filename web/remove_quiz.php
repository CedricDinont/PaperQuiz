<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Supprimer un quiz</title>
</head>
<body>
Fonctionnalité non disponible sur cette interface web.<br>
Demandez à Cédric Dinont pour supprimer un quiz.<br>
<br>
<?php  doMainMenu() ?>
</body>
</html>
