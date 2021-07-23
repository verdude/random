class BTnode {
  static order = [];
  static n = 0;

  constructor(val, left, right) {
    this.val = val;
    this.right = right;
    this.left = left;
  }

  /**
   * Get the entire ordered tree as a list
   * and return the nth node. (1 based indexing)
   * 1 being the smallest value.
   */
  nthSmallest(n) {
    if (n < 1) {
      throw new Error(`${n} is to small!!!!!`);
    }

    // clear static nodes
    BTnode.order = [];
    BTnode.n = n;
    this.ascending();
    return BTnode.order[n-1]
  }

  ascending() {
    if (BTnode.order.length === BTnode.n)
      return;

    if (this.left)
      this.left.ascending();

    BTnode.order.push(this);

    if (this.right)
      this.right.ascending();
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

function assert(success, test) {
  if (success) return;
  console.log(`Failed on `, test);
  console.log(BTnode.order);
  throw new Error(`failed on ${test}`);
}

[
  [1, 3],
  [2, 4],
  [3, 5],
  [4, 7],
  [5, 8],
  [6, 9],
  [7, 10],
].map(pair => {
  const [n, v] = pair;
  assert(tree.nthSmallest(n).val === v, n);
});

console.log("success");
