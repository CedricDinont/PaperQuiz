<?php
  require_once('quiz_common.php');
  // TODO gérer mieux la valeur par défaut des années...
  // récupération de la date
  $jour = date("j");
  $mois = date("m");
  $annee = date("Y");
?>
<html>
<head>
        <title>Création d'un quiz</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<?php
	if (isset($_POST['action']) && ($_POST['action'] == "create")) {
		$name = str_replace(' ','_',$_POST['quiz-name']);
		$quiz_name=$_POST['year']."_".$_POST['month']."_".$_POST['day']."-".$_POST['group']."-".$name;
		system($quiz_bin_dir."create_quiz.sh ".$quiz_name." &");
	} else {
?>
Veuillez renplir le formulaire suivant en respectant les règles suivantes :
<ul>
<li>La date est celle où les étudiants font le quiz.</li>
<li>Ne mettez aucun espace dans les champs. Les remplacer par des _.</li>
<li>Le nom du groupe d'étudiants doit commencer par le nom de la promo suivi éventuellement du sous-groupe concerné séparés par un _ (ex.: CLIIR1, ou N4_Unix).</li>
<li>L'intitulé doit permettre de reconnaître le sujet du quiz (ex. : TP1, DS).</li>
</ul>
<form action="create_quiz.php" method="post">
<input type="hidden" name="action" value="create">
<table>
<tr><td>Jour :</td><td> 
	<select name="day" class="form_elem">
	<?php
		for($i=1;$i<=31;$i++)
		{
			echo "<option";
			if($i == $jour)
			{
				echo " selected ";
			}
			echo ">";
			if(0<=$i && $i < 10)
			{
				echo "0".$i;
			}
			else
			{
				echo $i;
			}
			echo "</option>\n";
		}
	?>
	</select></td>
	</tr><tr><td>Mois : </td><td> 
	<select name="month" class="form_elem">
	<?php
		$tab_mois = array(1=>"Janvier",2=>"Février",3=>"Mars",4=>"Avril",5=>"Mai",6=>"Juin",7=>"Juillet",
		8=>"Août",9=>"Septembre",10=>"Octobre",11=>"Novembre",12=>"Décembre");
		for($i=1;$i<=12;$i++)
		{
			echo "<option value=\"";
			if(0<=$i && $i < 10)
			{
				echo "0".$i;
			}
			else
			{
				echo $i;
			}
			echo "\"";
			if($i == $mois)
			{
				echo " selected ";
			}
			
			echo ">".$tab_mois[$i]."</option>\n";
		}
	?>
        </select></td>
       </tr><tr><td>Année : </td><td> 
	<select name="year" class="form_elem">
	<?php
		for($i=$annee-1;$i<=$annee+2;$i++)
		{
			$val = $i-2000;
			echo "<option value=\"";
			if(0<=$val && $val < 10)
			{
				echo "0".$val;
			}
			else
			{
				echo $val;
			}
			echo "\"";
			if($i == $annee)
			{
				echo " selected ";
			}
			
			echo ">".($i)."</option>\n";
		}
	?>
	</select></td>
</tr><tr><td>Groupe d'étudiants :</td><td> <input type="text" name="group" class="form_elem"></td>
</tr><tr><td>Intitulé du quiz : </td><td><input type="text" name="quiz-name" class="form_elem"></td>
</table>
	<input type="submit" class="form_elem">
</form>
<?php }
  doMainMenu() ?>
</body>
</html>
