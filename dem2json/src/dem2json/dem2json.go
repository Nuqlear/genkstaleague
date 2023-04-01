package main

import (
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/dotabuff/manta"
	"github.com/gin-gonic/gin"
)

func ParseFromStream(stream io.Reader) (MatchData, error) {
	parser, err := manta.NewStreamParser(stream)
	var matchParser = MatchParser{}
	matchParser.init(parser)

	if err != nil {
		log.Println("Unable to create stream parser:", err)
		io.ReadAll(stream)
		return matchParser.matchData, err
	}

	parser.Callbacks.OnCDemoFileInfo(matchParser.OnCDemoFileInfo)
	parser.OnEntity(matchParser.OnEntity)
	parser.Callbacks.OnCMsgDOTACombatLogEntry(matchParser.OnCMsgDOTACombatLogEntry)
	parser.Callbacks.OnCDOTAMatchMetadataFile(matchParser.OnCDOTAMatchMetadataFile)
	parser.Callbacks.OnCSVCMsg_ServerInfo(matchParser.OnCSVCMsg_ServerInfo)

	err = parser.Start()
	if err != nil {
		log.Println("Unable to start stream parser:", err)
		io.ReadAll(stream)
		return matchParser.matchData, err
	}

	matchParser.finalize()
	return matchParser.matchData, nil
}

func main() {
	router := gin.Default()
	router.POST("/", func(c *gin.Context) {
		output, err := ParseFromStream(c.Request.Body)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprint(err)})
		} else {
			c.JSON(http.StatusOK, gin.H{"result": output})
		}
	})
	router.Run(":5222")
}
