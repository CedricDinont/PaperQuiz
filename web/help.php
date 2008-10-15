<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Aide</title>
</head>
<body>

<?php  doMainMenu() ?>

</body>
</html>
