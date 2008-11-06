<?php
require_once('Processus.class.php');
require_once('Quiz.class.php');
require_once('quiz_common.php');

$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Processus terminés</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php
$processes=Processus::getAllProcesses($quiz);
foreach ($processes as $pid => $processus) {
  echo "<a href=\"view_process_progress.php?quiz-id=".$quiz->getId()."&pid=".$processus->getPid()."\">".$processus->getCommand()." (PID ".$processus->getPid().")</a><br>";
}
?>
<br>
<?php  doMainMenu() ?>
</body>
</html>
