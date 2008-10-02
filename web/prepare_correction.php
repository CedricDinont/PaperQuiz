<?php

require_once('Processus.class.php');

Processus::startQuizScriptAndViewCreatedProcess($_GET['quiz-id'], "prepare_correction.sh");

?>
