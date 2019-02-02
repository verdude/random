package main

import (
	"fmt"
	"golang.org/x/tour/tree"
)

// Walk walks the tree t sending all values
// from the tree to the channel ch.
func Walk(t *tree.Tree, ch chan int) {
	if t.Left != nil {
		Walk(t.Left, ch)
	}
	ch <- t.Value
	if t.Right != nil {
		Walk(t.Right, ch)
	}
}

// Same determines whether the trees
// t1 and t2 contain the same values.
func Same(t1, t2 *tree.Tree) bool {
	ch1, ch2 := make(chan int, 1), make(chan int, 1)
	go Walk(t1, ch1)
	go Walk(t2, ch2)
	for i := 0; i < 10; i++ {
		if x, y := <-ch1, <-ch2; x != y {
			fmt.Println("Trees are not the same")
			return false
		} else {
			break
		}
	}
	fmt.Println("Trees are the same")
	return true
}

func main() {
	Same(tree.New(2), tree.New(1))
}
