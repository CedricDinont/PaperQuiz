<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');
   require_once('view_files_common.php');
	
	$quiz = Quiz::getQuizById($_GET['quiz-id']);
        doFileOperation();
        
   function displaydir($dir)
   {
   	echo "<ul>";
		$tab_files = getDirFiles($dir);
		$nb_group = sizeof($tab_files);
		$count_group = 0;
		foreach($tab_files as $group){
			echo "<li>";
			echo "<input class=\"selection\" type=\"button\" onClick=\"doSimpleinSection(this.parentNode,true);\" value=\"tous\"></input>";
			echo "<input class=\"selection\" type=\"button\" onClick=\"doSimpleinSection(this.parentNode,false);\" value=\"aucun\"></input>";
			$count_group++;
			if($count_group==$nb_group){
				echo "<ul class=\"last\">";
			} else {
				echo "<ul>";
			}
			$count = 0;
			$taille = sizeof($group);
			foreach($group as $tab_file){
				$count++;
				echo "<li>";
				if($count == $taille){
					echo "<img src=\"img/joinbottom.gif\"/>";
				} else {
					echo "<img src=\"img/join.gif\"/>";
				}
				if($tab_file != null && $tab_file["file"] != null){
					showFileFromDescription($tab_file);
				}
			}
			echo "</ul>";
			echo "</li>";
		}
		echo "</ul>";
   }
?>
<html>
<head>
	<title>Visualisation des fichiers liés à la reconnaissance des marques</title>
   <link rel="stylesheet" type="text/css" href="style/quiz.css" />
   <script type="text/javascript" src="./js/fichier.js"></script>
</head>
<body>

<form method="POST" action="view_omr_files.php?quiz-id=<?php echo $quiz->getId(); ?>" name="file_operations_form">

<div id="arborescence">
<h1>Fichiers du répertoire d'entrée</h1>
<?php
include("files_control.php.inc");
displaydir($quiz->getOmrInputDir());
?>
</div>

<div>
<h1>Fichiers du répertoire de sortie</h1>
<?php
include("files_control.php.inc");
displaydir($quiz->getOmrOutputDir());
?>
</div>

<div id="arborescence">
<h1>Fichiers du répertoire d'erreur</h1>
<?php
include("files_control.php.inc");
displaydir($quiz->getOmrErrorDir());
?>
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
