package main

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/dotabuff/manta"
	"github.com/dotabuff/manta/dota"
)

const EarlyTimeMinutes = 10

type MatchParser struct {
	matchData      MatchData
	gameTime       time.Duration
	realGameTime   time.Duration
	parser         *manta.Parser
	heroDamageMap  map[string]uint32
	towerDamageMap map[string]uint32
	damageTakenMap map[string]uint32
}

type MatchData struct {
	MatchID    uint64              `json:"match_id"`
	GameMode   int32               `json:"game_mode"`
	StartTime  uint32              `json:"start_time"`
	EndTime    uint32              `json:"end_time"`
	Duration   float32             `json:"duration"`
	RadiantWin bool                `json:"radiant_win"`
	Players    [10]MatchPlayerData `json:"players"`
	Draft      Draft               `json:"draft"`
}

type Draft struct {
	Captains     [2]int32  `json:"captains"`
	PicksAndBans []PickBan `json:"picks_and_bans"`
}

type PickBan struct {
	IsPick    bool   `json:"is_pick"`
	IsRadiant bool   `json:"is_radiant"`
	Hero      string `json:"hero"`
}

type MatchPlayerData struct {
	AccountId           uint64     `json:"account_id"`
	AccountIdOrig       uint64     `json:"account_id_orig"`
	HeroId              int32      `json:"hero_id"`
	HeroName            string     `json:"hero_name"`
	Kills               int32      `json:"kills"`
	Deaths              int32      `json:"deaths"`
	Assists             int32      `json:"assists"`
	LastHits            int32      `json:"last_hits"`
	Denies              int32      `json:"denies"`
	Level               int32      `json:"level"`
	PlayerSlot          int        `json:"player_slot"`
	GoldPerMin          int32      `json:"gold_per_min"`
	XpPerMin            int32      `json:"xp_per_min"`
	HeroDamage          uint32     `json:"hero_damage"`
	DamageTaken         uint32     `json:"damage_taken"`
	TowerDamage         uint32     `json:"tower_damage"`
	ObserverWardsPlaced int32      `json:"observer_wards_placed"`
	SentryWardsPlaced   int32      `json:"sentry_wards_placed"`
	EarlyDenies         int32      `json:"early_denies"`
	EarlyLastHits       int32      `json:"early_last_hits"`
	Items               [6]string  `json:"items"`
	Movement            []Position `json:"movement"`
}

type Position struct {
	X    uint64        `json:"x"`
	Y    uint64        `json:"y"`
	Time time.Duration `json:"time"`
}

func (matchParser *MatchParser) init(parser *manta.Parser) {
	matchParser.heroDamageMap = make(map[string]uint32)
	matchParser.towerDamageMap = make(map[string]uint32)
	matchParser.damageTakenMap = make(map[string]uint32)
	matchParser.parser = parser
	matchData := &matchParser.matchData
	for index := range matchData.Players {
		matchData.Players[index].HeroDamage = 0
		matchData.Players[index].DamageTaken = 0
		matchData.Players[index].TowerDamage = 0
	}
}

func (matchParser *MatchParser) finalize() {
	matchData := &matchParser.matchData
	for index, player := range matchData.Players {
		heroName := heroesMap[player.HeroId]
		matchData.Players[index].HeroName = heroName
		matchData.Players[index].HeroDamage = matchParser.heroDamageMap[heroName]
		matchData.Players[index].DamageTaken = matchParser.damageTakenMap[heroName]
		matchData.Players[index].TowerDamage = matchParser.towerDamageMap[heroName]
	}
}

func (matchParser *MatchParser) pull_CDOTAGamerulesProxy(entity *manta.Entity) {
	matchData := &matchParser.matchData
	if entity.GetClassName() == "CDOTAGamerulesProxy" {
		gameEndTime, _ := entity.GetFloat32("m_pGameRules.m_flGameEndTime")
		gameStartTime, _ := entity.GetFloat32("m_pGameRules.m_flGameStartTime")
		if gameTime, ok := entity.GetFloat32("m_pGameRules.m_fGameTime"); ok {
			matchParser.gameTime = time.Duration(gameTime) * time.Second
		}
		if gameStartTime != 0 {
			matchData.Duration = gameEndTime - gameStartTime
			matchParser.realGameTime = matchParser.gameTime - time.Duration(gameStartTime)*time.Second
		} else {
			matchParser.realGameTime = time.Duration(0)
		}
	}
}

func (matchParser *MatchParser) pull_CDOTA_PlayerResource(entity *manta.Entity) {
	matchData := &matchParser.matchData
	count := 0
	if entity.GetClassName() == "CDOTA_PlayerResource" {
		for count < 10 {
			matchPlayerData := matchData.Players[count]
			if count > 4 {
				matchPlayerData.PlayerSlot = count + 123
			} else {
				matchPlayerData.PlayerSlot = count
			}
			fetchFrom := "m_vecPlayerData.000" + strconv.Itoa(count)
			if result, ok := entity.GetUint64(fetchFrom + ".m_iPlayerSteamID"); ok && matchPlayerData.AccountId == 0 {
				matchPlayerData.AccountIdOrig = result
				// format account_id to match Web API version
				matchPlayerData.AccountId, _ = strconv.ParseUint(strconv.FormatUint(result, 10)[3:], 10, 64)
				matchPlayerData.AccountId -= 61197960265728
			}
			fetchFrom = "m_vecPlayerTeamData.000" + strconv.Itoa(count)
			if result, ok := entity.GetInt32(fetchFrom + ".m_nSelectedHeroID"); ok {
				matchPlayerData.HeroId = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iKills"); ok {
				matchPlayerData.Kills = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iDeaths"); ok {
				matchPlayerData.Deaths = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iAssists"); ok {
				matchPlayerData.Assists = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iLevel"); ok {
				matchPlayerData.Level = result
			}
			matchData.Players[count] = matchPlayerData
			count++
		}
	}
}

func (matchParser *MatchParser) pull_CDOTA_Data(entity *manta.Entity) {
	matchData := &matchParser.matchData
	count := 0
	if entity.GetClassName() == "CDOTA_DataRadiant" || entity.GetClassName() == "CDOTA_DataDire" {
		for count < 5 {
			realCount := count
			if strings.HasSuffix(entity.GetClassName(), "Dire") {
				realCount += 5
			}
			matchPlayerData := matchData.Players[realCount]
			fetchFrom := "m_vecDataTeam.000" + strconv.Itoa(count)
			duration := int32(matchData.Duration / 60)
			if result, ok := entity.GetInt32(fetchFrom + ".m_iTotalEarnedGold"); ok && duration != 0 {
				matchPlayerData.GoldPerMin = result / duration
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iTotalEarnedXP"); ok && duration != 0 {
				matchPlayerData.XpPerMin = result / duration
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iDenyCount"); ok {
				matchPlayerData.Denies = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iLastHitCount"); ok {
				matchPlayerData.LastHits = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iObserverWardsPlaced"); ok {
				matchPlayerData.ObserverWardsPlaced = result
			}
			if result, ok := entity.GetInt32(fetchFrom + ".m_iSentryWardsPlaced"); ok {
				matchPlayerData.SentryWardsPlaced = result
			}
			if matchParser.realGameTime < time.Duration(60*EarlyTimeMinutes)*time.Second {
				matchPlayerData.EarlyDenies = matchPlayerData.Denies
				matchPlayerData.EarlyLastHits = matchPlayerData.LastHits
			}
			matchData.Players[realCount] = matchPlayerData
			count++
		}
	}
}

func getRealCords(entity *manta.Entity) (realX uint64, realY uint64) {
	const (
		DefaultOffsetX = 64
		DefaultOffsetY = 63
		CellSize       = 1 << 7
	)
	cellX, _ := entity.GetUint64("CBodyComponent.m_cellX")
	cellY, _ := entity.GetUint64("CBodyComponent.m_cellY")
	offsetX, _ := entity.GetFloat32("CBodyComponent.m_vecX")
	offsetY, _ := entity.GetFloat32("CBodyComponent.m_vecY")
	realX = (cellX-DefaultOffsetX)*CellSize + uint64(offsetX)
	realY = (cellY-DefaultOffsetY)*CellSize + uint64(offsetY)
	return
}

func (matchParser *MatchParser) pull_CDOTA_Unit_Hero(entity *manta.Entity) {
	matchData := &matchParser.matchData
	const Magic = (1 << 14) - 1
	if strings.HasPrefix(entity.GetClassName(), "CDOTA_Unit_Hero") {
		hOwner, _ := entity.GetUint64("m_hOwnerEntity")
		ownerEntity := matchParser.parser.FindEntity(int32(hOwner & Magic))
		if ownerEntity != nil {
			// save movement
			playerID, _ := ownerEntity.GetInt32("m_iPlayerID")
			realX, realY := getRealCords(entity)
			playerData := &matchData.Players[playerID]
			// ignore movement after first EarlyTimeMinutes minutes of the game
			if matchParser.realGameTime > 0 && matchParser.realGameTime < time.Duration(60*EarlyTimeMinutes)*time.Second {
				// save position no more othen than for every 15 seconds
				interval := time.Duration(15) * time.Second
				if len(playerData.Movement) == 0 || playerData.Movement[len(playerData.Movement)-1].Time < matchParser.realGameTime+interval {
					matchData.Players[playerID].Movement = append(
						matchData.Players[playerID].Movement,
						Position{
							realX,
							realY,
							matchParser.realGameTime})
				}
			}
			// save items
			count := 0
			for count < 6 {
				hItem, _ := entity.GetUint32(fmt.Sprintf("m_hItems.%04d", count))
				itemEntity := matchParser.parser.FindEntity(int32(hItem & Magic))
				if itemEntity != nil {
					itemIndex, _ := itemEntity.GetInt32("m_pEntity.m_nameStringableIndex")
					itemName, _ := matchParser.parser.LookupStringByIndex("EntityNames", itemIndex)
					matchData.Players[playerID].Items[count] = itemName
				} else {
					matchData.Players[playerID].Items[count] = ""
				}
				count++
			}
		}
	}
}

func (matchParser *MatchParser) OnCDemoFileInfo(demoFileInfo *dota.CDemoFileInfo) error {
	matchData := &matchParser.matchData
	gameInfo := demoFileInfo.GetGameInfo().GetDota()
	matchData.MatchID = gameInfo.GetMatchId()
	matchData.GameMode = gameInfo.GetGameMode()
	matchData.RadiantWin = (gameInfo.GetGameWinner() == 2)
	// if Captains Mode
	if matchData.GameMode == 2 {
		for _, pickBan := range gameInfo.GetPicksBans() {
			matchData.Draft.PicksAndBans = append(
				matchData.Draft.PicksAndBans,
				PickBan{
					pickBan.GetIsPick(),
					pickBan.GetTeam() == 2,
					heroesMap[int32(pickBan.GetHeroId())]})
		}
	}
	matchData.StartTime = gameInfo.GetEndTime()
	matchData.EndTime = gameInfo.GetEndTime()
	return nil
}

func (matchParser *MatchParser) OnCDOTAMatchMetadataFile(metadataFile *dota.CDOTAMatchMetadataFile) error {
	matchData := &matchParser.matchData
	// for some reason there is 10 Teams
	// but 2-10 teams are the same
	teams := metadataFile.GetMetadata().GetTeams()
	// dire player slots starts from 123, not 5
	matchData.Draft.Captains = [2]int32{
		teams[0].GetCmCaptainPlayerId(), 123 + teams[1].GetCmCaptainPlayerId()}
	return nil
}

func (matchParser *MatchParser) OnEntity(entity *manta.Entity, entityOp manta.EntityOp) error {
	matchParser.pull_CDOTAGamerulesProxy(entity)
	matchParser.pull_CDOTA_PlayerResource(entity)
	matchParser.pull_CDOTA_Data(entity)
	matchParser.pull_CDOTA_Unit_Hero(entity)
	return nil
}

func (matchParser *MatchParser) OnCMsgDOTACombatLogEntry(combatLogEntry *dota.CMsgDOTACombatLogEntry) error {
	t := combatLogEntry.GetType()
	switch dota.DOTA_COMBATLOG_TYPES(t) {
	case dota.DOTA_COMBATLOG_TYPES_DOTA_COMBATLOG_DAMAGE:
		is_attacker_hero := combatLogEntry.GetIsAttackerHero() || combatLogEntry.GetIsAttackerIllusion()
		if is_attacker_hero && combatLogEntry.GetIsTargetHero() && !combatLogEntry.GetIsTargetIllusion() {
			attacker, _ := matchParser.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetDamageSourceName()))
			target, _ := matchParser.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetTargetSourceName()))
			if attacker != target {
				damage := combatLogEntry.GetValue()
				if _, ok := matchParser.heroDamageMap[attacker]; ok {
					matchParser.heroDamageMap[attacker] += damage
				} else {
					matchParser.heroDamageMap[attacker] = damage
				}
				if _, ok := matchParser.damageTakenMap[target]; ok {
					matchParser.damageTakenMap[target] += damage
				} else {
					matchParser.damageTakenMap[target] = damage
				}
			}
		} else if is_attacker_hero && combatLogEntry.GetIsTargetBuilding() {
			attacker, _ := matchParser.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetDamageSourceName()))
			damage := combatLogEntry.GetValue()
			if _, ok := matchParser.towerDamageMap[attacker]; ok {
				matchParser.towerDamageMap[attacker] += damage
			} else {
				matchParser.towerDamageMap[attacker] = damage
			}
		}
	}
	return nil
}
