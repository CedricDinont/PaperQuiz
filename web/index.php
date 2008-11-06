<?php
	require_once('Quiz.class.php');
?>
<html>
<head>
	<title>Quiz</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
Que voulez-vous faire ?
<ul>
<li><a href="create_quiz.php">Créer un quiz</a></li>
<li>Accéder à un quiz existant :
<form action="quiz_workflow.php" method="get">
<select name="quiz-id" class="form_elem">
<?php
$quizes=Quiz::getAllQuizes();
foreach ($quizes as $quiz_name => $quiz) {
   	echo "<option value=\"".$quiz->getId()."\">".$quiz->getName()."</option>";
}
?>
</select>
<input type="submit" value="Go" class="form_elem">
</form>
</li>
<li><a href="help.php">Lire l'aide</a></li>
</ul>
</body>
