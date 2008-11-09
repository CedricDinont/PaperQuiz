<?php

function endsWith( $str, $sub ) {
  return (strcmp(substr( $str, strlen( $str ) - strlen( $sub ) ), $sub ) == 0);
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

function showFile($dir, $file) {
    if (endsWith($file, "data") || endsWith($file, ".txt") || endsWith($file, "students") || endsWith($file, ".csv") || endsWith($file, ".marking") || endsWith($file, "corners") || endsWith($file, "answers") || endsWith($file, ".log")) {
      $page = "view_text_file_content";
    } else {
      $page = "view_file";
    }
      echo "<li><input type=\"checkbox\" name=\"files[]\" value=\"".$dir.$file."\"><a href=\"".$page.".php?quiz-id=".$_GET['quiz-id']."&filename=".$dir.$file."\">".$file."</a></li>";
}

function doFilesMenu() {
  echo "<script>function confirmAction() { if (confirm(\"Voulez-vous vraiment réaliser cette opération ?\")) { document.file_operations_form.submit(); } }  </script>";
  echo "Avec les fichiers choisis: ";
  echo "<select class=\"form_elem\" name=\"action\">";
  echo "<option value=\"move\">Déplacer dans un autre répertoire</option>";
  echo "<option value=\"remove\">Supprimer</option>";
  echo "</select><br>Répertoire destination : ";
  echo "<select class=\"form_elem\" name=\"dest_folder\">";
  echo "<option value=\"omr_input/\">omr_input</option>";
  echo "<option value=\"omr_output/\">omr_output</option>";
  echo "<option value=\"omr_errors/\">omr_errors</option>";
  echo "<option value=\"correction/\">correction</option>";
  echo "<option value=\"./\">base</option>";
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
    echo "<span style=\"color: red\"><bold>Le déplacement de fichiers n'est pas encore implémenté.<bold></span><br>";
    
    foreach ($_POST['files'] as $key => $file) {
      //rename($quiz->getDir().$file);
    }
  }
}

?> 
