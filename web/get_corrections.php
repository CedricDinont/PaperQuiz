<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Accès aux fichiers de résultats</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
Fichiers de résultats pour le quiz <?php echo $quiz->getName() ?> :<br>
<ul>
<?php
$no_file = true;
$d = dir($quiz->getCorrectionDir());
while (false !== ($entry = $d->read())) {
  if (substr_compare($entry, ".ods", strlen($entry) - 4) == 0) {
    $no_file = false;
    echo "<li><a href=\"view_file.php?quiz-id=".$_GET['quiz-id']."&attachment=true&filename=correction/",rawurlencode($entry),"\">".$entry."</a></li>";
  }
}
if ($no_file) {
  echo "<li>Aucun fichier de résultat n'a été généré pour l'instant.</li>";
}
?>
</ul>
<br>
<?php  doMainMenu() ?>
</body>
</html>
