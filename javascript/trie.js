var Trie = function() {
	const LETTER_OFFSET = 97;
	/**
	 * Node class
	 * each node has a value and an array of length 26
	 */
	function Node(char) {
		this.letters = new Array(26);
		var value = char || null;
		var freq = 0;
		var that = this;

		//instantiate letters array
		for (var i = 0; i < this.letters.length; ++i) {
			this.letters[i] = null;
		}
		/**
		 * Trie Class methods
		 */
		return {
			getValue: function() {return value;},
			incrementFreq: function() {freq++;},
			nodeAt: function(index) {
				return that.letters[index];
			}
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
					if (prevNode.nodeAt(letter.charCodeAt() - LETTER_OFFSET) === null) {
						var currNode = new Node(letter);
						if (lastLetter) 
							currNode.incrementFreq();
						console.log(prevNode.letters);
						prevNode.letters[letter.charCodeAt() - LETTER_OFFSET] = currNode;
						nodeCount++;
						prevNode = currNode;
					} else {
						prevNode = prevNode.nodeAt(letter.charCodeAt() - LETTER_OFFSET);
						if (lastLetter) 
							prevNode.incrementFreq();
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

trie.insert("santi");
trie.insert("sanet");

console.log(trie.getRoot());
console.log("Word Count: " + trie.getWordCount());
console.log("Node Count: " + trie.getNodeCount());