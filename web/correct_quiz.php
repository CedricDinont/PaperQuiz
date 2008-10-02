<?php

require_once('Processus.class.php');

Processus::startQuizScriptAndViewCreatedProcess($_GET['quiz-id'], "correct_quiz.sh");

?>