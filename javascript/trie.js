function Trie() {
	this.LETTER_OFFSET = 97;

	this.root = new Node();
	this.wordCount = 0;
}

Trie.prototype.insert = function(word) {
	var prevNode = this.root;
	var lowerCaseWord = word.toLowerCase();
	lowerCaseWord.split("").forEach(function(letter, index){
		var isLastLetter = index === lowerCaseWord.length - 1;
		if (prevNode.letters[letter.charCodeAt() - this.LETTER_OFFSET] !== null) {
			var currNode = new Node();
			currNode.value = letter;
			if (isLastLetter) currNode.freq++;
		}
	});
}

function Node() {
	this.letters = new Array(26);
	this.freq = 0;
	this.letter = "";

	// instantiate the array
	for (var i = 0; i < 26; i++) {
		this.letters[i] = null;
	}
}

var trie = new Trie;