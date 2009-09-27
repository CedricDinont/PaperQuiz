<?php
	require_once('Processus.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);

        if (isset($_GET['pid'])) {
	  $filename_base = $quiz->getProcessesDir().$_GET['pid'];
	  $hasToRefreshPage = FALSE;
	} else if ($quiz->hasRunningProcess()) {
	  $filename_base = "/tmp/".$quiz->getName();
	  $hasToRefreshPage = TRUE;
	} else {
	  $filename_base = $quiz->getProcessesDir().$quiz->getLastProcessPid();
	  $hasToRefreshPage = FALSE;
	}
?>
<html>
<head>
        <title>Visualisation des sorties du processus</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
<?php 
  if ($hasToRefreshPage) { ?>
	<meta http-equiv="refresh" content="5">
<?php } ?>
</head>
<body>
<?php doMainMenu(); ?>
<hr>
<table width="100%">
<tr>
<?php 
	  if ($hasToRefreshPage) {
	    echo "Process is running";
	  } else {
	    echo "Process is finished";
	  }
?>
<br><br>
	<th width="50%"><center>Sortie standard</center></th>
	<th><center>Erreur standard</center></th>
</tr>
<tr>
	  <td style="font-size:80%"><?php echo implode('<br>', file($filename_base.".stdout")); ?>&nbsp;</td>
	  <td style="font-size:80%"><?php echo implode('<br>', file($filename_base.".stderr")); ?>&nbsp;</td>
</tr>
</table>
<br>
<hr>
<?php doMainMenu(); ?>

</body>
