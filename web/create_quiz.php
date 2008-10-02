<?php
	require_once('config.php');
?>
<html>
<head>
        <title>Création d'un quiz</title>
</head>
<body>
<?php
	if ($_POST['action'] == "create") {
		$quiz_name=$_POST['year']."_".$_POST['month']."_".$_POST['day']."-".$_POST['group']."-".$_POST['quiz-name'];
		system($quiz_bin_dir."create_quiz.sh ".$quiz_name." &");
	} else {
?>

<form action="create_quiz.php" method="post">
<input type="hidden" name="action" value="create">
	Jour : 
	<select name="day">
		<option>01</option>
                <option>02</option>
                <option>03</option>
                <option>04</option>
                <option>05</option>
                <option>06</option>
                <option>07</option>
                <option>08</option>
                <option>09</option>
                <option>10</option>
                <option>11</option>
                <option>12</option>
                <option>13</option>
                <option>14</option>
                <option>15</option>
                <option>16</option>
                <option>17</option>
                <option>18</option>
                <option>19</option>
                <option>20</option>
                <option>21</option>
                <option>22</option>
                <option>23</option>
                <option>24</option>
                <option>25</option>
                <option>26</option>
                <option>27</option>
                <option>28</option>
                <option>29</option>
                <option>30</option>
		<option>31</option>
	</select>
	<br>
	Mois : 
	<select name="month">
                <option value="01">Janvier</option>
                <option value="02">Février</option>
	        <option value="03">Mars</option>
                <option value="04">Avril</option>
                <option value="05">Mai</option>
                <option value="06">Juin</option>
                <option value="07">Juillet</option>
                <option value="08">Août</option>
                <option value="09">Septembre</option>
                <option value="10">Octobre</option>
                <option value="11">Novembre</option>
                <option value="12">Décembre</option>
        </select>
	<br>
	Année : 
	<select name="year">
		<option value="08">2008</option>
		<option value="09">2009</option>
		<option value="10">2010</option>
		<option value="11">2011</option>
	</select>
	<br>
	Nom du groupe d'étudiants concerné : <input type="text" name="group"><br>
	Intitulé du quiz : <input type="text" name="quiz-name"><br>
	<input type="submit" value="doCreateQuiz">
	<input type="submit" value="cancelCreateQuiz" onclick="javascript:>
</form>
<?php
}
?>
</body>
