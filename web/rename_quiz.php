<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$q = Quiz::getQuizById($_GET['quiz-id']);

          if ($q->hasRunningProcess()) {
                        echo "<html><head><title>Erreur</title></head><body>Erreur: un processus est actif pour ce quiz. Vous ne pouvez pas le renommer actuellement.<br><br>";
                        global $quiz;
                        $quiz = $q;
                        doMainMenu();
                        echo "</body></html>";
                        exit();
          }

	$quiz = $q;

?>
<html>
<head>
	<title>Renommer un quiz</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php
	if (isset($_POST['action']) && ($_POST['action'] == "rename")) {
	  $new_dir_name=str_replace($quiz->getName(), $_POST['new-name'], $quiz->getDir());
	  if (rename($quiz->getDir(), $new_dir_name)) {
	    echo "Renommage réussi.<br>";
	    $quiz = Quiz::getQuizByName($_POST['new-name']);
	  } else {
	    echo "<br>Erreur: impossible de renommer le quiz.<br>";
	  }
	} else {
?>
<form method="POST" action="rename_quiz.php?quiz-id=<?php echo $_GET['quiz-id']; ?>">
<input type="hidden" name="action" value="rename">
<table>
<tr><td>Ancien nom : </td><td><?php echo $quiz->getName(); ?></td></tr>
<tr><td>Nouveau nom : </td><td><input class="form_elem" type="text" name="new-name" size="40" value="<?php echo $quiz->getName(); ?>"></td></tr>
</table>
	<input type="submit" class="form_elem">
</form>
  <?php } ?>
<br>
<?php  doMainMenu() ?>
</body>
</html>
