<?php
require_once('Processus.class.php');
require_once('Quiz.class.php');

$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Processus actifs</title>
</head>
<body>
<?php
$processes=Processus::getAllProcesses($quiz);
foreach ($processes as $pid => $processus) {
  echo "<a href=\"".$processus->getPid()."\">".$processus->getPid()."</a><br>";
}
?>

</body>

