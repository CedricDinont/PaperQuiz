<?php
        require_once('Quiz.class.php');
        require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<html>
<head>
        <title>Récupérer les images scannées depuis le FTP de dev.isen.fr</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php  doMainMenu() ?>
<hr>
<?php
$nbFiles = 0;
if ($handle = opendir($ftp_dir)) {
    while (false !== ($file = readdir($handle))) {
        if ($file != "." && $file != "..") {
	    $files[$nbFiles] = $file;
            $nbFiles++;
        }
    }
    closedir($handle);
}
?>
<?php 
if ($nbFiles == 0) {
	echo "Aucun fichier à récupérer sur le FTP.";
} else {
	$nbErrors = 0;
	echo "Déplacement des fichiers suivants du FTP vers le répertoire d'entrée de la reconnaissance des marques pour le quiz ".$quiz->getName()." :";
	echo "<ul>"; 
	foreach ($files as $nb => $file) {
		echo "<li>".$file."    ";
		if (rename($ftp_dir.$file, $quiz->getDir()."omr_input/".$file) == TRUE) {
			echo "[OK]";
		} else {
			echo "[ERROR]";
			$nbErrors++;
		}
		echo "</li>";
	}
	echo "</ul>";
	if ($nbErrors == 0) {
		echo "Déplacement de ".$nbFiles." fichiers effectué avec succès.";
	} else {
		echo "Il y a eu ".$nbErrors." durant le déplacement de ".$nbFiles." fichiers.";
	}
}
?>
<br /><br />
<hr>
<?php  doMainMenu() ?>
</body>
</html>

