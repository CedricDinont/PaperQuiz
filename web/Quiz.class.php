<?php

include('config.php');

class Quiz {
	private $name;

	private function __construct($quiz_name) {
		$this->name = $quiz_name;
		// TODO: Check if the quiz directory exists
	}

	public static function createQuiz($quiz_name) {
                // TODO: Call create_quiz.sh script
		return new Quiz($quiz_name);
	}

	public static function getQuizByName($quiz_name) {
		return new Quiz($quiz_name);
	}

	public static function getQuizById($quiz_id) {
	        global $quiz_data_dir;

                $d = dir($quiz_data_dir);
                while ((false !== ($entry = $d->read())) && ($quiz_id != md5($entry))) {
                }
                $d->close();
		if ($quiz_id == md5($entry)) 
			return new Quiz($entry);
		else
                	return null;
	}

	public static function getAllQuizes() {
		global $quiz_data_dir;

		$quizes = array();
		$d = dir($quiz_data_dir);
		while (false !== ($entry = $d->read())) {
		  if ($entry[0] != '.') {
		    $quizes[$entry] = new Quiz($entry);
		  }
		}
		$d->close();
		rsort($quizes);
		return $quizes;
	}

	public function getName() {
		return $this->name;
	}

	public function getId() {
		return md5($this->name);
	}

	public function getDir() {
		global $quiz_data_dir;

		return $quiz_data_dir.$this->getName()."/";
	}

	public function getProcessesDir() {
		return $this->getDir()."processes/";
	}

	public function getCorrectionDir() {
		return $this->getDir()."correction/";
	}

	public function getOmrInputDir() {
		return $this->getDir()."omr_input/";
	}

	public function getOmrOutputDir() {
		return $this->getDir()."omr_output/";
	}

	public function getOmrErrorDir() {
		return $this->getDir()."omr_errors/";
	}


	public function hasRunningProcess() {
		$contents = file($this->getProcessesDir()."current_process");
		if (($contents != FALSE) && ($contents[0] === "Running\n")) {
			return TRUE;
		} else {
			return FALSE;
		}
	}

	public function getLastProcessPid() {
		$contents = file($this->getProcessesDir()."current_process");
		if (($contents != FALSE) && ($contents[0] === "Finished\n")) {
		  return trim($contents[1]);
		} else {
			return FALSE;
		}
	}

	public function rename($new_name) {

	}

	public function getDate() {
		$quiz_name_fields = split("-", $this->name);
		$date = $quiz_name_fields[0];
		$date_fields = split("_", $date);
		$timestamp = mktime(0, 0, 0, $date_fields[1], $date_fields[2], $date_fields[0]);
		return $timestamp;
	}

}

?>
