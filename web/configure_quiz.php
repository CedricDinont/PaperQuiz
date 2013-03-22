<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
        $nb_quiz_parts = 10;
?>
<?php $page_title='Configuration du quiz'; include 'header.php' ?>
<?php
if (isset($_GET['action'])) {
  $file = fopen($quiz->getDir() . "quiz.conf", "w");
  for ($i = 0; $i < $nb_quiz_parts; $i++) {
    if (strcmp($_POST['quiz_part_'.$i], "") != 0) {
      fprintf($file, "%s:%s:%s\n", $_POST['quiz_part_'.$i], $_POST['min_question_'.$i], $_POST['max_question_'.$i]);
    }
  }
  fclose($file);
  echo "Modifications prises en compte.";
} else {
?>

<form method="POST" action="configure_quiz.php?action=save_changes&quiz-id=<?php echo $_GET['quiz-id']; ?>">
<table>
<tr>
  <th>Matière</th><th>Questions</th>
</tr>
<?php
  $file_content = file($quiz->getDir() . "quiz.conf");
  $line_nb = 0;
for ($i = 0; $i < $nb_quiz_parts; $i++) {
  $quiz_part = "";
  $question_min = "";
  $question_max = "";
  if ($line_nb < count($file_content)) {
    if (strncmp($file_content[$line_nb], "#", 1) != 0) {
      $line = split(":", $file_content[$line_nb++]);
      if (count($line) == 3) {
	$quiz_part = $line[0];
	$question_min = $line[1];
	$question_max = $line[2];
      }
    }
  }
  //<span class=\"add-on\">...</span>
  
  echo "<tr><td><input type=\"text\" placeholder=\"Matière\" name=\"quiz_part_".$i."\" value=\"".$quiz_part."\"></input></td>
	    <td>
		<input class=\"span2\" placeholder=\"à partir de\" type=\"text\" name=\"min_question_".$i."\" value=\"".$question_min."\"></input>
		<input class=\"span2\" placeholder=\"jusqu'à\" type=\"text\" name=\"max_question_".$i."\" value=\"".$question_max."\"></input>
		</div></td></tr>";
}
?>
</table>
<button type="submit" class="btn btn-primary">Enregistrer</button>
</form>

<?php
    }
?>

<br>
<?php  doMainMenu() ?>
<?php include 'footer.html' ?>