<?php
  require_once('quiz_common.php');
  // TODO gérer mieux la valeur par défaut des années...
  // récupération de la date
  $jour = date("j");
  $mois = date("m");
  $annee = date("Y");
?>
<?php $page_title='Création d\'un quiz'; include 'header.php' ?>
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
<li>Le nom du groupe d'étudiants doit commencer par le nom de la promo suivi éventuellement du sous-groupe concerné séparés par un _ (ex.: CIR1, ou M1_Unix).</li>
<li>L'intitulé doit permettre de reconnaître le sujet du quiz (ex. : TP1, DS).</li>
</ul>
<form action="create_quiz.php" class="form-horizontal" method="post">
<input type="hidden" name="action" value="create">
  <div class="control-group">
    <label class="control-label" for="day">Jour&nbsp;:</label>
    <div class="controls">
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
	</select>
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="month">Mois&nbsp;:</label>
    <div class="controls">
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
        </select>
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="year">Année&nbsp;:</label>
    <div class="controls">
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
	</select>
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="group">Groupe d'étudiants&nbsp;:</label>
    <div class="controls">
      <input type="text" name="group" class="form_elem">
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="quiz-name">Intitulé du quiz&nbsp;:</label>
    <div class="controls">
      <input type="text" name="quiz-name" class="form_elem">
    </div>
  </div>
  <div class="control-group">
    <div class="controls">
      <button type="submit" class="btn btn-primary">Créer le quiz</button>
    </div>
  </div>
</form>
<?php }
  doMainMenu() ?>
<?php include 'footer.html' ?>