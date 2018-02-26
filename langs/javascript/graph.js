
var graph = {
    val: "Santiago",
    al: []
}

function Graph() {
    this.nodes = [];
}

Graph.prototype.depthFirstPrint = function() {
    function visit(node) {
        if (node == null) return;
        node.visit = true;
        console.log(node.val);
        node.al.forEach(n => {
            if (!n.visited)
                visit(n);
        });
    };

    console.log("Starting depth first print");
    this.nodes.forEach(n => {
        if (!n.visited)
            visit(n);
    });
};

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
        if ( edge.length !== 2 )
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
        cities: ["Provo", "Austin", "Seattle", "NYC"],
        tickets: [ ["Provo", "Austin"], ["Provo", "Seattle"], ["Seattle", "Austin"], ["Austin", "NYC"], ["NYC", "Provo"] ]
    };

    return createGraph(nodesAndEdges.cities, nodesAndEdges.tickets);
}

var g = tickets();
//g.depthFirstPrint();

