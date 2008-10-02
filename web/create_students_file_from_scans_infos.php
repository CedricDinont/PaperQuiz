<?php

require_once('Processus.class.php');

Processus::startQuizScriptAndViewCreatedProcess($_GET['quiz-id'], "create_students_file_from_scans_infos.sh");

?>