package main

import (
    "fmt"
    "os"
)


func main() {
    output := ParseDemo("/Users/nuqlya/1948506460.dem")
    fmt.Println(string(output))
}