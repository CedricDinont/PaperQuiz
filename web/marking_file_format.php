<?php
        require_once('Quiz.class.php');
        require_once('quiz_common.php');

if (isset($_GET['quiz-id'])) {
        $quiz = Quiz::getQuizById($_GET['quiz-id']);
  }
?>
<html>
<head>
        <title>Format de fichier des corrigés</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
</head>
<body>
<h1>Format de fichier des corrigés</h1>
Chaque ligne correspond à la description d'une question. On peut insérer des commentaires avec le caractère # en début de ligne.<br />
<br/ >
Chaque ligne de description d'une question est un ensemble de champs séparés par un point-virgule. Les 3 premiers champs sont obligatoires. Tous les autres sont optionnels. Si on spécifie un champ optionnel, on n'est pas obligé de spécifier ceux qui le suivent.
Pour l'instant, si l'on veut spécifier la valeur d'un champ optionnel, il faut obligatoirement spécifier les champs optionnels qui le précèdent. Benjamin va évaluer la possibilité de ne pas donner de valeur à certains champs optionnels pour utiliser la valeur par défaut.<br />
<br />
Voici la liste des champs :
<ol>
<li>
<b>Numéro de la question sur la feuille de réponses</b> ou 0 (zéro) pour une question ouverte.
</li>
<li>
<b>Numéro de la dernière réponse possible</b> (entre 1 et 5).
</li>
<li>
<b>Réponse(s) attendue(s).</b> Le format est le suivant :
	<ul>
		<li>
			Rx indique que la réponse numéro x est une bonne réponse. Par exemple R1.	
		</li>
		<li>
			On peut combiner plusieurs bonnes réponses avec le caractère \. Par exemple R1\R2.
		</li>
                <li>
			On peut remplacer le R par un O (lettre o majuscule) si la question n'attend qu'une seule bonne réponse et que l'ensemble des réponses proposées est exclusif (il est impossible qu'il y ait plusieurs bonnes réponses). Si un étudiant coche plusieurs réponses à cette question, un warning s'affichera lors du processus de correction.
                </li>
                <li>
			Il est possible d'utiliser la notation Xx pour indiquer que la question ne dispose pas de la réponse numéro x. Cela est utile quand on veut aligner certains types de réponses sur plusieurs questions et donc créer des trous dans la liste des réponses possibles. Si un étudiant coche la réponse numéro x, cela générera un warning lors du processus de correction.
                </li>
	</ul>
</li>
<li>
<b>Bonus (1 par défaut).</b> Points à attribuer pour l'ensemble des bonnes coches sur la question. Si la question attend n coches, chaque coche vaut bonus/n.
</li>
<li>
<b>Malus (-0.5 par défaut).</b> Points à attribuer pour les mauvaises coches. Chaque mauvaise coche vaut malus/n, avec n le nombre de coches attendues pour la question.
</li>
<li>
<b>Coefficient (1 par défaut).</b> Poids de la question par rapport aux autres questions. L'ensemble des coefficents des questions forme leur barycentre. Pour calculer la note finale, on additionne les points pour chaque coche (bonus et malus) pour une question donnée. On multiplie par le coefficient de la question et on additionne avec le résultat du même calcul pour les autres questions. Enfin, on normalise la note sur 20 points.
</li>
<li>
<b>Bonus forcé (0 par défaut).</b> Si ce champ est différent de 0, on ne prend pas du tout en compte les coches faites par les étudiants pour la question. La note de la question est remplacée pour tous les étudiants par le bonus forcé. Le coefficient de la question est appliqué à cette note. Ce champ est utile pour annuler une question en faisant bénéficier tous les étudiants des points qu'ils auraient pu avoir s'ils avaient bien répondu.
</li>
<li>
<b>Limite basse de malus (-100 par défaut).</b> L'étudiant ne peut pas perdre plus que ce nombre de points sur la question. Cela permet de limiter les effets du malus quand il y a peu de coches attendues pour une question et que l'étudiant fait beaucoup de mauvaises coches sur cette question. En effet, avec les bonus/malus par défaut, si 1 coche est attendue et que l'étudiant coche les 4 autres choix, il a normalement 4 fois le malus complet, c'est-à-dire -2 sur cette question, ce qui est énorme.
</li>
<li>
<b>Champs additionnels.</b> Apparaissent dans le fichier OpenOffice mais ne sont pas utilisés pour la correction.
</li>
</ol>
<br>
<?php  doMainMenu() ?>

</body>
</html>

