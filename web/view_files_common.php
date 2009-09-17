<?php

function endsWith( $str, $sub ) {
  return (strcmp(getEnd($str,$sub), $sub ) == 0);
}

function getEnd($str, $sub ){
	return substr( $str, strlen( $str ) - strlen( $sub ) );
}

function getStrWithoutEnd($str, $sub ){
	return substr( $str, 0 , strlen( $str ) - strlen( $sub ) );
}

function showDirFiles($dir) {
  global $quiz;
  $files = array();
  $i = 0;
  $d = dir($dir);
  $short_dir = str_replace($quiz->getDir(), "", $dir);
  while (false !== ($entry = $d->read())) {
    if ($entry[0] != '.') {
      $files[$i++] = $entry;
    }
  }
  sort($files);
  foreach ($files as $nb => $file) {
   	showFile($short_dir, $file);
  }
 }
 
 function getDirFiles($dir){
  global $quiz;
  $files = array();
  $i = 0;
  $d = dir($dir);
  $short_dir = str_replace($quiz->getDir(), "", $dir);
  while (false !== ($entry = $d->read())) {
    if ($entry[0] != '.') {
      $files[$i++] = $entry;
    }
  }
  $tab_fic = array();
  sort($files);
  foreach ($files as $nb => $file) {
  		$fic = getFile($short_dir, $file);
  		$keys = array_keys($fic);
  		$key = $keys[0];
  		if(!array_key_exists($key,$tab_fic)){
  			$tab_fic[$key] = array();
  		}
  		array_push($tab_fic[$key],$fic[$key]);
  }
  return $tab_fic;
 }

function showFile($dir, $file) {
    if (endsWith($file, "data") || endsWith($file, ".txt") || endsWith($file, "students") || endsWith($file, ".csv") || endsWith($file, ".marking") || endsWith($file, "corners") || endsWith($file, "answers") || endsWith($file, ".log")) {
      $page = "view_text_file_content";
    } else {
      $page = "view_file";
    }
    
    $types=array("data",".txt",".students",".csv",".marking",".corners",".answers",".log");
    $types_fic = array(".jpg",".jpg.mmr_data",".jpg.omr_data",".jpg.omr1_data",".jpg.omr2_data",".jpg.omr3_data",".jpg_binarized.jpg",".jpg_corrected.jpg"
    ,".jpg_corrected2.jpg",".jpg_corrected3.jpg");
    
    $type = "";
    foreach($types as $test)
    {
    	if(endsWith($file, $test)){
    		$type = $test;
    	}
    }
    
    $nom_fic = "";
    foreach($types_fic as $test_fic)
    {
    	if(strpos($file,$test_fic) >0){
    		$nom_fic = getStrWithoutEnd($file,$test_fic);
    	}
    }
    
    echo "<li><input ";
    if($type != ""){
    	echo "type_fichier=\"".$type."\" ";
    }
    if($nom_fic != ""){
    	echo "fichier=\"".$nom_fic."\" ";
    }
    echo "type=\"checkbox\" name=\"files[]\" value=\"".$dir.$file."\"><a href=\"".$page.".php?quiz-id=".$_GET['quiz-id']."&filename=".$dir.$file."\">".$file."</a></li>\n";
}

function getFile($dir, $file) {
    if (endsWith($file, "data") || endsWith($file, ".txt") || endsWith($file, "students") || endsWith($file, ".csv") || endsWith($file, ".marking") || endsWith($file, "corners") || endsWith($file, "answers") || endsWith($file, ".log")) {
      $page = "view_text_file_content";
    } else {
      $page = "view_file";
    }
    
    $types=array(".jpg",".jpg.omr_data",".jpg.omr1_data",".jpg.omr2_data",".jpg.omr3_data",".jpg_binarized.jpg",".jpg_corrected.jpg"
    ,".jpg_corrected2.jpg",".jpg_corrected3.jpg",".txt",".students",".csv",".marking",".corners",".answers",".log");
    $types_fic = array(".jpg",".jpg.mmr_data",".jpg.omr_data",".jpg.omr1_data",".jpg.omr2_data",".jpg.omr3_data",".jpg_binarized.jpg",".jpg_corrected.jpg"
    ,".jpg_corrected2.jpg",".jpg_corrected3.jpg");
    
    $type = "";
    foreach($types as $test)
    {
    	if(endsWith($file, $test)){
    		$type = $test;
    	}
    }
    
    $nom_fic = "";
    foreach($types_fic as $test_fic)
    {
    	if(strpos($file,$test_fic) >0){
    		$nom_fic = getStrWithoutEnd($file,$test_fic);
    	}
    }
    return array($nom_fic=>array("file"=>$file,"chemin"=>$dir.$file,"page"=>$page,"type_fichier"=>$type,"fichier"=>$nom_fic,"quiz-id"=>$_GET['quiz-id']));
}

function showFileFromDescription($tab_file){
	 echo "<input ";
    if($tab_file["type_fichier"] != ""){
    	echo "type_fichier=\"".$tab_file["type_fichier"]."\" ";
    }
    if($tab_file["fichier"] != ""){
    	echo "fichier=\"".$tab_file["fichier"]."\" ";
    }
    echo "type=\"checkbox\" name=\"files[]\" value=\"".$tab_file["chemin"]."\"><a href=\"".$tab_file["page"].
    ".php?quiz-id=".$tab_file["quiz-id"]."&filename=".$tab_file["chemin"]."\">".$tab_file["file"]."</a>\n";
}


function doFilesMenu() {
  echo "<script>function confirmAction() { if (confirm(\"Voulez-vous vraiment réaliser cette opération ?\")) { document.file_operations_form.submit(); } }  </script>";
  echo "Avec les fichiers choisis: ";
  echo "<select class=\"form_elem\" name=\"action\">";
  echo "<option value=\"move\">Déplacer dans un autre répertoire</option>";
  echo "<option value=\"remove\">Supprimer</option>";
  echo "</select><br>Répertoire destination : ";
  echo "<select class=\"form_elem\" name=\"dest_folder\">";
  echo "<option value=\"omr_input\">omr_input</option>";
  echo "<option value=\"omr_output\">omr_output</option>";
  echo "<option value=\"omr_errors\">omr_errors</option>";
  echo "<option value=\"correction\">correction</option>";
  echo "<option value=\".\">base</option>";
  echo "</select><br>";
  echo "<input type=\"submit\" class=\"form_elem\" onclick=\"confirmAction(); return false;\">";
}

function doFileOperation() {
  global $quiz;

  if (! isset($_POST['action']))
    return;

  if ($_POST['action'] == "remove") {
    foreach ($_POST['files'] as $key => $file) {
      unlink($quiz->getDir().$file);
    }
  } else if ($_POST['action'] == "move") {    
    foreach ($_POST['files'] as $key => $file) {
      $elems = explode("/", $file);
      $filename = $elems[count($elems) - 1];
      $new_file = $quiz->getDir().$_POST['dest_folder']."/".$filename;
      rename($quiz->getDir().$file, $new_file);
    }
  }
}

?> 
