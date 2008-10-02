<?php

require_once('Processus.class.php');

Processus::startQuizScriptAndViewCreatedProcess($_GET['quiz-id'], "fetch_scans_from_mail.sh");

?>


