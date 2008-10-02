<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Renommer un quiz</title>
</head>
<body>
<form>
Ancien nom :  <br>
Nouveau nom :  <br>
</form>
<br>
<?php  doMainMenu() ?>
</body>
</html>