package main

import (
	"io"
	"net/http"

	"github.com/dotabuff/manta"
	"github.com/gin-gonic/gin"
)

func ParseFromStream(stream io.Reader) MatchData {
	parser, _ := manta.NewStreamParser(stream)
	var matchParser = MatchParser{}
	matchParser.init(parser)

	parser.Callbacks.OnCDemoFileInfo(matchParser.OnCDemoFileInfo)
	parser.OnEntity(matchParser.OnEntity)
	parser.Callbacks.OnCMsgDOTACombatLogEntry(matchParser.OnCMsgDOTACombatLogEntry)
	parser.Callbacks.OnCDOTAMatchMetadataFile(matchParser.OnCDOTAMatchMetadataFile)
	parser.Start()

	matchParser.finalize()
	return matchParser.matchData
}

func main() {
	router := gin.Default()
	router.POST("/", func(c *gin.Context) {
		output := ParseFromStream(c.Request.Body)
		c.JSON(http.StatusOK, gin.H{"result": output})
	})
	router.Run(":5222")
}
