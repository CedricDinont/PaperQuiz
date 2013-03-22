<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

	$quiz = Quiz::getQuizById($_GET['quiz-id']);
?>
<?php $page_title='Supprimer un quiz'; include 'header.php' ?>
Fonctionnalité non disponible sur cette interface web.<br>
	  Demandez à <?php echo $admin_name; ?> pour supprimer un quiz.<br>
<br>
<?php  doMainMenu() ?>
<?php include 'footer.html' ?>