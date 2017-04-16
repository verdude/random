var HashTable = function() {
	var length = 0;
	var table = {};

	return {
		insert: function(key, value) {
			// if the key is new
			if (!table.hasOwnProperty(key)) {
				length++;
			}
			// create or overwrite the value
			table[key] = value;
		},
	
		get: function(key) {
			return table[key];
		},
	
		remove: function(key) {
			if (table.hasOwnProperty(key)) {
				delete table[key];
				length--;
			}
		},
	
		clear: function() {
			Object.keys(table).forEach(function(key){
				delete table[key];
			});
			length = 0;
		},

		print: function() {
			console.log(table);
		}
	}
}

var table = new HashTable();

table.insert("Santi", {age:24, college:"BYU", homeState: "New Jersey"});


table.insert("Jerkson", {age:22,college:"BYU",homeState:"Utah"});
table.remove("blah");
table.remove("Santi");

