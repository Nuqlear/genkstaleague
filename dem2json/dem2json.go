package main

import (
    "fmt"
    "os"
)


func main() {
    if len(os.Args) != 2 {
        fmt.Println("Usage: dem2json REPLAY_FILE.dem")
        return
    } else {
        filePath := os.Args[1]
        if _, err := os.Stat(filePath); os.IsNotExist(err) {
            fmt.Printf("ERROR: %s doesnt exist\n", filePath)
            return
        } else {
            output := ParseFromFile(filePath)
            fmt.Println(string(output))
        }
    }
}