<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);
        checkParentDirectoryInFilename($_GET['filename']);
?>
<html>
<head>
        <title>Contenu du fichier texte</title>
</head>
<body>
<?php
  $file_content = file($quiz->getDir() . $_GET['filename']);
foreach ($file_content as $line_num => $line) {
    echo htmlspecialchars($line) . "<br />\n";
}
?>
</body>
</html>