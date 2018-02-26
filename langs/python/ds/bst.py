
class BST():
    def __init__(self, val=None):
        self.val = val
        self.left = None
        self.right = None

    def insert(self, val, currnode=None):
        if currnode == None:
            currnode = self

        if currnode.val == None:
            currnode.val = val

        elif val <= currnode.val:
            if currnode.left == None:
                currnode.left = BST(val)
            else:
                self.insert(val, currnode.left)

        elif val > currnode.val:
            if currnode.right == None:
                currnode.right = BST(val)
            else:
                self.insert(val, currnode.right)

    def inOrderTraversal(self, node=None):
        if node == None:
            node = self

        if node.left != None:
            self.inOrderTraversal(node.left)

        print(node.val)

        if node.right != None:
            self.inOrderTraversal(node.right)

    def preOrderTraversal(self, node=None):
        if node == None:
            node = self

        print(node.val)

        if node.left != None:
            self.preOrderTraversal(node.left)

        if node.right != None:
            self.preOrderTraversal(node.right)

    def postOrderTraversal(self, node=None):
        if node == None:
            node = self

        if node.right != None:
            self.postOrderTraversal(node.right)

        if node.left != None:
            self.postOrderTraversal(node.left)

        print(node.val)


if __name__ == "__main__":
    values = [ "santiago", "verdu", "brun", "carbonell", "perex" ]
    tree = BST()
    for val in values:
        tree.insert( val )

    print()
    print("in order:")
    tree.inOrderTraversal()
    print()
    print("pre order:")
    tree.preOrderTraversal()
    print()
    print("post order:")
    tree.postOrderTraversal()

