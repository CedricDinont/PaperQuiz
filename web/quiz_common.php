<?php

function doMainMenu() {
	global $quiz;

	echo "<div class=\"MainMenu\"><a href=\"index.php\">Retour au menu principal</a> - <a href=\"quiz_workflow.php?quiz-id=".$quiz->getId()."\">Retour au menu du quiz</a> - <a href=\"help.php?quiz-id=".$quiz->getId()."\">Aide</a></div>";
}

?>
