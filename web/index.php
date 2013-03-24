<?php
	require_once('Quiz.class.php');

	$max_date = strtotime("- 1 month -1 day");
?>
<?php $active_page='home'; $page_title='Quiz'; include 'header.php' ?>
<script>
	function init() {
		size1 = document.getElementById("current_month_quizes").style.width;
		size2 = document.getElementById("old_quizes").style.width;
		if (size1 < size2) {
			document.getElementById("current_month_quizes").style.width = size2;
		} else {
			document.getElementById("old_quizes").style.width = size1;
		}
	}
</script>
Que voulez-vous faire ?
<ul>
<li><a class="btn btn-primary" href="create_quiz.php"><i class="icon-file-alt"></i> Créer un quiz</a></li>
<li>Accéder à un quiz existant :
<ul>
<li> 
<form action="quiz_workflow.php" method="get">
Dernier mois :<br /> 
<?php
$quizes=Quiz::getAllQuizes();
$nb_quizes = 0;
foreach ($quizes as $quiz_name => $quiz) {
        if ($quiz->getDate() >= $max_date) {
        	$nb_quizes++;
	}
}
?>
<table>
<tr valign="top">
<td style="border:0px;">
<select name="quiz-id" class="form_elem" id="current_month_quizes" size="<?php echo $nb_quizes; ?>">
<?php
$quizes=Quiz::getAllQuizes();
foreach ($quizes as $quiz_name => $quiz) {
	if ($quiz->getDate() >= $max_date) {
	   	echo "<option value=\"".$quiz->getId()."\">".$quiz->getName()."</option>";
	}
}
?>
</select>
</td><td style="border:0px;">
<button type="submit" class="btn btn-primary"><i class="icon-folder-open"></i> Go</button>
</td>
</tr>
</table>
</form>
</li>
<li>
<form action="quiz_workflow.php" class="form-horizontal" method="get">
Archives : <br/>
<select name="quiz-id" class="form_elem" id="old_quizes">
<?php
$quizes=Quiz::getAllQuizes();
foreach ($quizes as $quiz_name => $quiz) {
        if ($quiz->getDate() < $max_date) {
                echo "<option value=\"".$quiz->getId()."\">".$quiz->getName()."</option>";
        }
}
?>
</select>
<button type="submit" class="btn btn-primary"><i class="icon-folder-open"></i> Go</button>
</li>
</ul>
</form>

</li>
</ul>
<?php include 'footer.html' ?>