var Trie = function() {
	const LETTER_OFFSET = 97;
	/**
	 * Node class
	 * each node has a value and an array of length 26
	 */
	function Node(char) {
		var value = char || null;
		var array = new Array(26);
		var freq = 0;

		//instantiate array
		for (var i = 0; i < array.length; ++i) {
			array[i] = null;
		}
		/**
		 * Trie Class methods
		 */
		return {
			getArray: function() {return array;},
			getValue: function() {return value;},
			incrementFreq: function() {freq++;}
		}	
	}

	/**
	 * Finds a word in the trie
	 * @return the the node with the freq set for that word or null
	 */
	function find(word) {

	}

	var root = new Node();
	var nodeCount = 0;
	var wordCount = 0;

	return {
		insert: function(word) {
			if (typeof word === "string") {
				var prevNode = root;
				var lowerCaseWord = word.toLowerCase();
				lowerCaseWord.split("").forEach(function(letter, index) {
					var lastLetter = index === lowerCaseWord.length - 1 ? true: false;
					if (prevNode[letter.charCodeAt() - LETTER_OFFSET] === null) {
						var currNode = new Node(letter);
						if (lastLetter) currNode.incrementFreq();
						prevNode[letter.charCodeAt() - LETTER_OFFSET] = currNode;
						nodeCount++;
						prevNode = currNode;
					} else {
						prevNode = prevNode[letter.charCodeAt() - LETTER_OFFSET];
						if (lastLetter) prevNode.incrementFreq();
					}
				});
				wordCount++;
			} else {
				console.log("Word is not a string");
			}
		},
		remove: function(word) {

		},
		contains: function(word) {

		},
		getRoot: function() {return root;},
		getWordCount: function() {return wordCount;},
		getNodeCount: function() {return nodeCount;}
	}
}

var trie = new Trie();

trie.insert("santi3");
trie.insert

console.log(trie.getRoot());
console.log(trie.getWordCount());