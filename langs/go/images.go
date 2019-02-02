package main

import "golang.org/x/tour/pic"
import "image"
import "image/color"

type Image struct{}

func (img Image) Bounds() image.Rectangle {
	return image.Rect(0, 0, 1, 1)
}

func (img Image) ColorModel() color.RGBAModel {
	return nil
}

func (img Image) At(x, y int) color.Color {
	return nil
}

func main() {
	m := Image{}
	pic.ShowImage(m)
}

