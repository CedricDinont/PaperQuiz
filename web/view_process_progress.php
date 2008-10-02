<?php
	require_once('Processus.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);

	if ($quiz->hasRunningProcess()) {
	  $filename_base = "/tmp/".$quiz->getName();
	  $hasToRefreshPage = TRUE;
	} else if (isset($_GET['pid'])) {
	  $filename_base = $quiz->getProcessesDir().$_GET['pid'];
	  $hasToRefreshPage = FALSE;
	} else {
	  $filename_base = $quiz->getProcessesDir().$quiz->getLastProcessPid();
	  $hasToRefreshPage = FALSE;
	}
?>
<html>
<head>
        <title>Visualisation des sorties du processus</title>
<?php 
  if ($hasToRefreshPage) { ?>
	<meta http-equiv="refresh" content="5">
<?php } ?>
</head>
<body>
<table border="1" width="100%">
<tr>
<?php 
	  if ($hasToRefreshPage) {
	    echo "Process is running";
	  } else {
	    echo "Process is finished";
	  }
?>
	<td width="50%"><center>Sortie standard</center></td>
	<td><center>Erreur standard</center></td>
</tr>
<tr>
	<td><?php echo implode('<br>', file($filename_base.".stdout")); ?></td>
	<td><?php echo implode('<br>', file($filename_base.".stderr")); ?></td>
</tr>
</table>

<?php doMainMenu(); ?>

</body>
