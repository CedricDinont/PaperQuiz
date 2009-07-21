/*
explore le document à partir de la node spécifiée
recherche toutes les checkbox et inverse son status
*/
function invertAllinSection(elem){
	var xpathResult = document.evaluate(".//input", elem, null, XPathResult.ANY_TYPE, null);
	try {
  		var thisNode = xpathResult.iterateNext();
	   while (thisNode) {
	     thisNode.checked = !thisNode.checked;
		  thisNode = xpathResult.iterateNext();
	   }
	}
	catch (e) {
	   dump( 'Erreur :'+e);
	}
}

/*
explore le document à partir de la node spécifiée
recherche toutes les checkbox et les met à l'état spécifié
*/
function doSimpleinSection(elem,flag){
	var xpathResult = document.evaluate(".//input", elem, null, XPathResult.ANY_TYPE, null);
	try {
  		var thisNode = xpathResult.iterateNext();
	   while (thisNode) {
	     thisNode.checked = flag;
		  thisNode = xpathResult.iterateNext();
	   }
	}
	catch (e) {
	   dump( 'Erreur :'+e);
	}
}

/*
explore le document à partir de la node spécifiée
recherche toutes les checkbox dont l'attribut type_fichier vaut ".jpg", identifiant une image et les met à l'état spécifié
*/
function doinSection(elem,attribut,valeur,flag){
	var xpathResult = document.evaluate(".//input[attribute::"+attribut+"=\""+valeur+"\"]", elem, null, XPathResult.ANY_TYPE, null);
	try {
  		var thisNode = xpathResult.iterateNext();
	   while (thisNode) {
	     thisNode.checked = flag;
		  thisNode = xpathResult.iterateNext();
	   }
	}
	catch (e) {
	   dump( 'Erreur :'+e);
	}
}
