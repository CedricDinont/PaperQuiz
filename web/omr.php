<?php
require_once('Processus.class.php');
require_once('Quiz.class.php');

$quiz = Quiz::getQuizById($_GET['quiz-id']);

$p = Processus::createBackgroundProcess($quiz, $quiz_bin_dir."omr.sh ".$quiz->getName());
echo $p->getPid();
?>
<html>
<head>
        <meta http-equiv="REFRESH" content="0; URL=./view_process_progress.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">
        <title>Lancement de la reconnaissance des marques</title>
</head>
<body>
   Redirection
</body>