<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');
   require_once('view_files_common.php');
	
	$quiz = Quiz::getQuizById($_GET['quiz-id']);
        doFileOperation();
?>
<html>
<head>
	<title>Visualisation des fichiers liés à la reconnaissance des marques</title>
   <link rel="stylesheet" type="text/css" href="style/quiz.css" />
   <script type="text/javascript" src="./js/fichier.js"></script>
</head>
<body>

<form method="POST" action="view_omr_files.php?quiz-id=<?php echo $quiz->getId(); ?>" name="file_operations_form">

<div>
<h1>Fichiers du répertoire d'entrée</h1>
<?php
include("files_control.php.inc");
?>
<ul>
<?php
$tab_files = getDirFiles($quiz->getOmrInputDir());
foreach($tab_files as $group){
	?>
	<li>
	<input type="button" onClick="invertAllinSection(this.parentNode);" value="tous"></input>
	<ul>
	<?php
	foreach($group as $tab_file){
		if($tab_file != null && $tab_file["file"] != null){
			showFileFromDescription($tab_file);
		}
	}
	?>
	</ul>
	</li>
	<?php
}
?>
</ul>
</div>

<div>
<h1>Fichiers du répertoire de sortie</h1>
<?php
include("files_control.php.inc");
?>
<ul>
<?php
$tab_files = getDirFiles($quiz->getOmrOutputDir());
foreach($tab_files as $group){
	?>
	<li>
	<input type="button" onClick="invertAllinSection(this.parentNode);" value="tous"></input>
	<ul>
	<?php
	foreach($group as $tab_file){
		if($tab_file != null && $tab_file["file"] != null){
			showFileFromDescription($tab_file);
		}
	}
	?>
	</ul>
	</li>
	<?php
}
?>
</ul>
</div>

<div>
<h1>Fichiers du répertoire d'erreur</h1>
<?php
include("files_control.php.inc");
?>
<ul>
<?php
$tab_files = getDirFiles($quiz->getOmrErrorDir());
foreach($tab_files as $group){
	?>
	<li>
	<input type="button" onClick="invertAllinSection(this.parentNode);" value="tous"></input>
	<ul>
	<?php
	foreach($group as $tab_file){
		if($tab_file != null && $tab_file["file"] != null){
			showFileFromDescription($tab_file);
		}
	}
	?>
	</ul>
	</li>
	<?php
}
?>
</ul>
</div>

<div>
<h1>Autres fichiers</h1>
<ul>
<?php showFile("./", "omr.log"); ?>
</ul>
</div>

<br><br>

<?php doFilesMenu(); ?>
</form>
<br><br>
<br>
<?php  doMainMenu() ?>
</body>
</html>
