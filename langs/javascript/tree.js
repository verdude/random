const assert = require("assert");

class BTnode {
  constructor(val, left, right) {
    this.val = val;
    this.right = right;
    this.left = left;
  }

  /**
   * Build list of n nodes in ascending order,
   * return final one.
   */
  nthSmallest(n) {
    if (n < 1)
      throw new Error(`${n} is to small!!!!!`);

    let nodes = [];

    function orderNodes(node) {
      if (node.left)
        orderNodes(node.left);

      if (nodes.length === n)
        return;

      nodes.push(node);

      if (node.right)
        orderNodes(node.right);
    }

    orderNodes(this);

    if (nodes.length < n)
      throw new Error(`Cannot find ${n}th/rd/st/nd node. There are only ${nodes.length} in the tree.`);

    return nodes.pop();
  }
}

/*
 *         10
 *        /
 *       9
 *      /
 *     8
 *    /
 *   7
 *  /
 * 3
 *  \
 *   5
 *  /
 * 4
 *
 */
const tree = new BTnode(10, new BTnode(9, new BTnode(8, new BTnode(7, new BTnode(3, null, new BTnode(5, new BTnode(4)))))));

[
  [1, 3],
  [2, 4],
  [3, 5],
  [4, 7],
  [5, 8],
  [6, 9],
  [7, 10],
].map(pair => {
  const [nth, expected] = pair;
  const val = tree.nthSmallest(nth).val;
  console.log("Testing", pair, "received", val);
  assert(val === expected);
});

assert.throws(tree.nthSmallest.bind(tree, 100), Error);
assert.throws(tree.nthSmallest.bind(tree, 0), Error);

console.log("success");
