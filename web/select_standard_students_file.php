<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Sélection d'un fichier d'information sur les étudiants</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php
	if (isset($_POST['action']) && ($_POST['action'] == "update-students-file")) {
	  $src_file = $students_dir . $_POST['students-file'];
	  $dst_file = $quiz->getCorrectionDir() . "students";
	  if (copy($src_file, $dst_file)) {
	    echo "Opération réussie.<br>";
	  } else {
	    echo "<br>Erreur: impossible de copier le fichier.<br>";
	  }
	} else {
?>

Fichier d'informations sur les étudiants :
<form method="POST" action="select_standard_students_file.php?quiz-id=<?php echo $_GET['quiz-id'] ?>">
<input type="hidden" name="action" value="update-students-file">
<select name="students-file" class="form_elem">
<?php
$d = dir($students_dir);
while (false !== ($entry = $d->read())) {
  if ($entry[0] != '.') {
    echo "<option value=\"".$entry."\">".$entry."</option>";
  }
}
?>
</select>
<input type="submit" class="form_elem">
</form>
  <?php } ?>
<br>
<?php  doMainMenu() ?>
</body>
</html>