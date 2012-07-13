<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
	<title>Déposer un fichier de correction</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php
if (isset($_POST['action']) && ($_POST['action'] == "upload-marking")) {
  foreach ($_FILES["marking_files"]["error"] as $key => $error) {
    if ($error == UPLOAD_ERR_OK) {
        $tmp_name = $_FILES["marking_files"]["tmp_name"][$key];
        $name = $_FILES["marking_files"]["name"][$key];
        move_uploaded_file($tmp_name, $quiz->getDir().$key.".marking");
	echo "Correction mise à jour pour la matière '".$key."'.<br>";
    } else {
      echo "Pas de mise à jour du fichier de correction pour la matière'".$key."'.<br>";
    }
  }
  echo "<br>Upload terminé.<br>";
} else {
?>
  Sélection des fichiers de correction pour le quiz <?php echo $quiz->getName(); ?>.
<br><br>
Veuillez sélectionner le fichier correspondant à chaque matière.<br>Vous pouvez envoyer un ou plusieurs fichiers à la fois.<br>Les anciens fichiers de correction éventuellement présents sur le serveur  seront remplacés.<br><br>
<form method="POST" enctype="multipart/form-data" action="upload_marking.php?&quiz-id=<?php echo $_GET['quiz-id']; ?>">
<input type="hidden" name="action" value="upload-marking">
<table border>
<?php
$file_content = file($quiz->getDir() . "quiz.conf");
foreach ($file_content as $line_nb => $line) {
  if (strncmp($line, "#", 1) != 0) {
    $params = split(":", $line);
    if (count($params) == 3) {
      $quiz_part = $params[0];
      echo "<tr><td>Matière : ".$quiz_part."</td><td>Fichier : <input class=\"form_elem\" type=\"file\" name=\"marking_files[".$quiz_part."]\"></td></tr>";
    }
  }
}
?>
</table>
<input type="submit" class="form_elem"></input>
</form>

<?php
    }
?>

<br>
<?php  doMainMenu() ?>
</body>
</html>
