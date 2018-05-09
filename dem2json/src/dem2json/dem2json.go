package main

import (
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/dotabuff/manta"
)


func ParseFromStream(stream io.Reader) MatchData {
	parser, _ := manta.NewStreamParser(stream)
	var matchData = MatchData{}
	matchData.init(parser)

	parser.Callbacks.OnCDemoFileInfo(matchData.OnCDemoFileInfo)
	parser.OnEntity(matchData.OnEntity)
	parser.Callbacks.OnCMsgDOTACombatLogEntry(matchData.OnCMsgDOTACombatLogEntry)
	parser.Start()

	matchData.finalize()
    return matchData
}


func main() {
	router := gin.Default()
	router.POST("/", func(c *gin.Context) {
		output := ParseFromStream(c.Request.Body)
        c.JSON(http.StatusOK, gin.H{"result":output})
	})
	router.Run(":5222")
}
