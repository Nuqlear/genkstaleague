package main

import (
    "fmt"
    "os"
    "io"
    "encoding/json"

    "github.com/dotabuff/manta"
)


func ParseFromStream(stream io.Reader) string {
    parser, _ := manta.NewStreamParser(stream)
    var matchData = MatchData{}
    matchData.init(parser)

    parser.Callbacks.OnCDemoFileInfo(matchData.OnCDemoFileInfo)
    parser.OnEntity(matchData.OnEntity)
    parser.Callbacks.OnCMsgDOTACombatLogEntry(matchData.OnCMsgDOTACombatLogEntry)
    parser.Start()

    matchData.finalize()
    jsonOutput, _ := json.Marshal(map[string]MatchData{"result":matchData})
    return string(jsonOutput)
}


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
            file, _ := os.Open(filePath)
            output := ParseFromStream(file)
            fmt.Println(string(output))
        }
    }
}
