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
Fichiers de résultats pour le quiz <?php echo $quiz->getName() ?> :<br>
<?php
$no_file = true;
$d = dir($quiz->getCorrectionDir());
while (false !== ($entry = $d->read())) {
  if (substr_compare($entry, ".ods", strlen($entry) - 4) == 0) {
    $no_file = false;
    echo "<a href=\"view_file.php?quiz-id=".$_GET['quiz-id']."&attachment=true&filename=correction/".$entry."\">".$entry."</a><br>";
  }
}
if ($no_file) {
  echo "Aucun fichier de résultat n'a été généré pour l'instant.<br>";
}
?>
<br>
<?php  doMainMenu() ?>
</body>
</html>