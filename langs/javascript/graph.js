
function Graph() {
    this.nodes = [];
}

//===================================

Graph.prototype.unvisit = function(node) {
    if (node == null) return;
    node.visited = false;
    node.al.forEach(n => {
        if (n.visited)
            this.unvisit(n);
    });
};

Graph.prototype.reset = function() {
    this.nodes.forEach(n => {
        if (n.visited)
            this.unvisit(n)
    });
};

//===================================

// not working properly
Graph.prototype.kHopsBf = function(from, to, k) {
    var rootNode = this.nodes.find( n => n.val === from);
    if (typeof(k) !== "number") {
        console.log(k, "is not a number.");
        // should throw error instead
        return -1;
    }
    k = Math.floor(k);
    if (rootNode == undefined) {
        console.log(from, "Not found in this graph");
        return -1;
    }
    var queue = [];
    //rootNode.visited = true;
    queue.push(rootNode);
    var hops = 0;
    var rounds = 0;
    var levelTotals = [1];
    var found = false;

    while (queue.length !== 0) {
        let node = queue.shift();
        if (hops === k) {
            if (node.val === to) {
                found = true;
                break;
            }
        } else if (hops > k) {
            console.log("Exiting with", hops, "hops");
            break;
        }
        // update # of nodes we have viewed in this level of adj list
        rounds++;
        if (rounds === levelTotals[0]) {
            rounds = 0;
            levelTotals.shift();
            hops++;
        }
        // set the number of nodes in the newest adj list
        let num = 0;
        node.al.forEach( n => {
            num++;
            queue.push(n);
        });
        levelTotals.push(num);
    }
    if (found) {
        console.log("Took", hops, "hops to get to", to, "from", from);
    }
    this.reset();
    return found;
};

Graph.prototype.bfHops = function(from, to) {
    var rootNode = this.nodes.find( n => n.val === from);
    if (rootNode == undefined) {
        console.log(from, "Not found in this graph");
        return -1;
    }
    var queue = [];
    rootNode.visited = true;
    queue.push(rootNode);
    var hops = -1;
    var found = false;

    while (queue.length !== 0) {
        let node = queue.shift();
        if (node.val === to) {
            found = true;
            break;
        }
        node.al.forEach( n => {
            if (!n.visited) {
                n.visited = true;
                queue.push(n);
            }
        });
        hops++;
    }
    this.reset();
    if (found) {
        console.log("Took", hops, "hops to get to", to, "from", from);
        return hops;
    } else return -1;
};

Graph.prototype.breadthFirstSearch = function() {
    var rootNode = this.nodes.length > 0 ? this.nodes[0] : new Gnode();
    var queue = [];
    rootNode.visited = true;
    queue.push(rootNode);

    while (queue.length !== 0) {
        let node = queue.shift();
        console.log(node.val);
        node.al.forEach( n => {
            if (!n.visited) {
                n.visited = true;
                queue.push(n);
            }
        });
    }
};

//===================================

Graph.prototype.visit = function(node, f) {
    if (node == null) return;
    node.visited = true;
    f(node.val);
    node.al.forEach(n => {
        if (!n.visited)
            this.visit(n, f);
    });
};

Graph.prototype.dfhelper = function(node, to, k, hops, f) {
    if (node == null) return false;
    //f(node.val);
    hops++;
    if (hops === k) {
        if (node.val === to) {
            return true;
        }
        else {
            console.log("hiihi")
            hops--;
            return false;
        }
    }
    else if (hops > k) {
        console.log("shouldn't ever get here")
        hops--;
        return false;
    }
    else {
        for (let i= 0; i < node.al.length; i++) {
            return this.dfhelper(node.al[i], f, k, hops, f);
        }
    }
};

Graph.prototype.kHopsDf = function(from, to, k) {
    var fromNode = this.nodes.find(n => n.val === from);
    return this.dfhelper(fromNode, to, k, -1, console.log);
};

Graph.prototype.depthFirstPrint = function() {
    console.log("Starting depth first print");
    this.nodes.forEach(n => {
        if (!n.visited)
            this.visit(n, console.log);
    });
    console.log("Done with Depth first print");
};

//===================================

function Gnode(val, al) {
    this.val = val;
    this.visited = false;
    this.al = al || [];
}

Gnode.prototype.addNode = function(node) {
    this.al.push(node);
};

Gnode.prototype.visit = function() {
    this.visited = true;
};

function createGraph(nodes, edges) {
    //var n = new Gnode
    var graph = new Graph();
    graph.nodes = nodes.map(node => new Gnode(node));

    edges.forEach((edge) => {
        if ( !edge instanceof Array || edge.length !== 2 )
            return;
        
        let fromNode = graph.nodes.find(n => n.val === edge[0]);
        let toNode = graph.nodes.find(n => n.val === edge[1]);
        if (fromNode === undefined || toNode === undefined) {
            console.log(edge);
            console.log(fromIndex, toIndex);
            return;
        }
        fromNode.addNode(toNode);
    });

    return graph;
}


function tickets() {
    var nodesAndEdges = {
        cities: ["Provo", "Austin", "London", "Dubai", "Moscow", "Hong Kong", "SLC", "Shanghai", "Seattle", "NYC"],
        tickets: [ ["Provo", "Austin"], ["Provo", "Seattle"], ["NYC", "London"], ["London", "Dubai"], ["Dubai", "Moscow"], ["Moscow", "Shanghai"], ["Shanghai", "Hong Kong"], ["Shanghai", "Moscow"], ["London", "NYC"], ["Hong Kong", "Moscow"], ["Hong Kong", "Dubai"], ["Seattle", "Austin"], ["Austin", "NYC"], ["NYC", "Provo"], ["Provo", "Shanghai"] ]
    };

    return createGraph(nodesAndEdges.cities, nodesAndEdges.tickets);
}

var g = tickets();
g.breadthFirstSearch();
g.reset();

module = module || {};
module.exports = g;
