<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');
        require_once('view_files_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
        doFileOperation();
?>
<html>
<head>
	<title>Visualisation des fichiers liés à la correction</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<form method="POST" action="view_correction_files.php?quiz-id=<?php echo $quiz->getId(); ?>" name="file_operations_form">
<h1>Fichiers du répertoire de correction</h1>
<ul>
<?php showDirFiles($quiz->getCorrectionDir()) ?>
</ul>

<h1>Fichiers de correction</h1>
<ul>
<?php
  $files = array();
  $i = 0;
  $d = dir($quiz->getDir());
  while (false !== ($entry = $d->read())) {
    if (endsWith($entry, ".marking")) {
      $files[$i++] = $entry;
    }
  }
  sort($files);
  foreach ($files as $nb => $file) {
    showFile("", $file);
  }

?>
</ul>

<?php doFilesMenu(); ?>
</form>
<br><br>
<br>
<?php  doMainMenu() ?>
</body>
</html>