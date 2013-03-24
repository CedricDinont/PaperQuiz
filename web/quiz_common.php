<?php

require_once('config.php');

function doMainMenu() {
	global $quiz;

	echo "<div class=\"MainMenu\"><a href=\"index.php\"><i class=\"icon-home\"></i> Retour au menu principal</a>";
	if (isset($quiz)) {
	  echo " - <a href=\"quiz_workflow.php?quiz-id=".$quiz->getId()."\"><i class=\"icon-tasks\"></i> Retour au menu du quiz</a>";
	}
	echo "</div>";
}

function checkParentDirectoryInFilename($filename) {
  if (strstr($filename, "..") != FALSE) {
    echo "What are you trying to do?";
    exit(0);
  }
}

?>
