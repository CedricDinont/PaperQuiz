<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<?php $page_title='Accès aux fichiers de résultats'; include 'header.php' ?>

<p>Fichiers de résultats pour le quiz <?php if ($quiz) echo $quiz->getName(); else echo 'inconnu' ?> :</p>
<ul>
<?php
$no_file = true;
$d = dir($quiz->getCorrectionDir());
while (false !== ($entry = $d->read())) {
  if (substr_compare($entry, ".csv", strlen($entry) - 4) == 0) {
    $no_file = false;
    echo "<li><a href=\"view_file.php?quiz-id=".$_GET['quiz-id']."&attachment=true&filename=correction/",rawurlencode($entry),"\"><i class='icon-download'></i> ".$entry."</a></li>";
  }
}
if ($no_file) {
  echo "<li class='error'>Aucun fichier CSV de résultat n'a été généré pour l'instant.</li>";
}
?>
</ul>
<br>
<?php  doMainMenu() ?>
<?php include 'footer.html' ?>