package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/dotabuff/manta"
	"github.com/dotabuff/manta/dota"
)

type MatchPlayerData struct {
	AccountId     uint64   `json:"account_id"`
	AccountIdOrig uint64   `json:"account_id_orig"`
	HeroId        int32    `json:"hero_id"`
	HeroName      string   `json:"hero_name"`
	Kills         int32    `json:"kills"`
	Deaths        int32    `json:"deaths"`
	Assists       int32    `json:"assists"`
	LastHits      int32    `json:"last_hits"`
	Denies        int32    `json:"denies"`
	Level         int32    `json:"level"`
	PlayerSlot    int      `json:"player_slot"`
	GoldPerMin    int32    `json:"gold_per_min"`
	XpPerMin      int32    `json:"xp_per_min"`
	HeroDamage    uint32   `json:"hero_damage"`
	DamageTaken   uint32   `json:"damage_taken"`
	TowerDamage   uint32   `json:"tower_damage"`
	Items         []string `json:"items"`
}

type CMDraft struct {
	Captains  [2]uint32   `json:"captains"`
	PicksBans []CMPickBan `json:"picks_bans"`
}

type CMPickBan struct {
	IsPick    bool   `json:"is_pick"`
	IsRadiant bool   `json:"is_radiant"`
	Hero      string `json:"hero"`
}

type MatchData struct {
	MatchId    uint64              `json:"match_id"`
	GameMode   int32               `json:"game_mode"`
	StartTime  uint32              `json:"start_time"`
	EndTime    uint32              `json:"end_time"`
	Duration   float32             `json:"duration"`
	RadiantWin bool                `json:"radiant_win"`
	Players    [10]MatchPlayerData `json:"players"`
	CMDraft    CMDraft             `json:"cm_draft"`

	parser         *manta.Parser
	heroItemsMap   map[string][]string
	heroDamageMap  map[string]uint32
	towerDamageMap map[string]uint32
	damageTakenMap map[string]uint32
}

func (matchData *MatchData) init(parser *manta.Parser) {
	matchData.heroDamageMap = make(map[string]uint32)
	matchData.towerDamageMap = make(map[string]uint32)
	matchData.damageTakenMap = make(map[string]uint32)
	matchData.heroItemsMap = make(map[string][]string)
	for index, _ := range matchData.Players {
		matchData.Players[index].HeroDamage = 0
		matchData.Players[index].DamageTaken = 0
		matchData.Players[index].TowerDamage = 0
	}
	matchData.parser = parser
}

func (matchData *MatchData) finalize() {
	for index, player := range matchData.Players {
		heroName := heroesMap[player.HeroId]
		matchData.Players[index].Items = matchData.heroItemsMap[heroName]
		matchData.Players[index].HeroName = heroName
		matchData.Players[index].HeroDamage = matchData.heroDamageMap[heroName]
		matchData.Players[index].DamageTaken = matchData.damageTakenMap[heroName]
		matchData.Players[index].TowerDamage = matchData.towerDamageMap[heroName]
	}
}

func (matchData *MatchData) pull_CDOTAGamerulesProxy(entity *manta.Entity) {
	if entity.GetClassName() == "CDOTAGamerulesProxy" {
		gameEndTime, _ := entity.GetFloat32("m_pGameRules.m_flGameEndTime")
		gameStartTime, _ := entity.GetFloat32("m_pGameRules.m_flGameStartTime")
		matchData.Duration = gameEndTime - gameStartTime
	}
}

func (matchData *MatchData) pull_CDOTA_PlayerResource(entity *manta.Entity) {
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

func (matchData *MatchData) pull_CDOTA_Data(entity *manta.Entity) {
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
			matchData.Players[realCount] = matchPlayerData
			count++
		}
	}
}

func (matchData *MatchData) pull_CDOTA_Unit_Hero(entity *manta.Entity) {
	const MAGIC = (1 << 14) - 1
	if strings.HasPrefix(entity.GetClassName(), "CDOTA_Unit_Hero") {
		// https://github.com/dotabuff/manta/issues/104
		// it should be possible to connect items to players through m_iPlayerID entity property
		// but Valve somehow changed the way integers are stored
		// so this hacky workaround is the only easy way for now i guess
		heroName := normalizeUnitHeroEntityClassName(entity.GetClassName())
		if _, ok := matchData.heroItemsMap[heroName]; !ok {
			matchData.heroItemsMap[heroName] = make([]string, 6)
		}
		count := 0
		for count < 6 {
			hItem, _ := entity.GetUint32(fmt.Sprintf("m_hItems.%04d", count))
			itemEntity := matchData.parser.FindEntity(int32(hItem & MAGIC))
			if itemEntity != nil {
				itemIndex, _ := itemEntity.GetInt32("m_pEntity.m_nameStringableIndex")
				itemName, _ := matchData.parser.LookupStringByIndex("EntityNames", itemIndex)
				matchData.heroItemsMap[heroName][count] = itemName
			} else {
				matchData.heroItemsMap[heroName][count] = ""
			}
			count++
		}
	}
}

func (matchData *MatchData) OnCDemoFileInfo(demoFileInfo *dota.CDemoFileInfo) error {
	gameInfo := demoFileInfo.GetGameInfo().GetDota()
	matchData.MatchId = gameInfo.GetMatchId()
	matchData.GameMode = gameInfo.GetGameMode()
	matchData.RadiantWin = (gameInfo.GetGameWinner() == 2)
	// if Captains Mode
	if matchData.GameMode == 2 {
		for _, pickBan := range gameInfo.GetPicksBans() {
			matchData.CMDraft.PicksBans = append(
				matchData.CMDraft.PicksBans,
				CMPickBan{
					pickBan.GetIsPick(),
					pickBan.GetTeam() == 2,
					heroesMap[int32(pickBan.GetHeroId())]})
		}
	}
	matchData.StartTime = gameInfo.GetEndTime()
	matchData.EndTime = gameInfo.GetEndTime()
	return nil
}

func (matchData *MatchData) OnCDOTAMatchMetadataFile(metadataFile *dota.CDOTAMatchMetadataFile) error {
	// for some reason there is 10 Teams
	// but 2-10 teams are the same
	teams := metadataFile.GetMetadata().GetTeams()
	// dire player slots starts from 123, not 5
	matchData.CMDraft.Captains = [2]uint32{
		teams[0].GetCmCaptainPlayerId(), 123 + teams[1].GetCmCaptainPlayerId()}
	return nil
}

func (matchData *MatchData) OnEntity(entity *manta.Entity, entityOp manta.EntityOp) error {
	matchData.pull_CDOTAGamerulesProxy(entity)
	matchData.pull_CDOTA_PlayerResource(entity)
	matchData.pull_CDOTA_Data(entity)
	matchData.pull_CDOTA_Unit_Hero(entity)
	return nil
}

func (matchData *MatchData) OnCMsgDOTACombatLogEntry(combatLogEntry *dota.CMsgDOTACombatLogEntry) error {
	t := combatLogEntry.GetType()
	switch dota.DOTA_COMBATLOG_TYPES(t) {
	case dota.DOTA_COMBATLOG_TYPES_DOTA_COMBATLOG_DAMAGE:
		if (combatLogEntry.GetIsAttackerHero() || combatLogEntry.GetIsAttackerIllusion()) && combatLogEntry.GetIsTargetHero() && !combatLogEntry.GetIsTargetIllusion() {
			attacker, _ := matchData.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetDamageSourceName()))
			target, _ := matchData.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetTargetSourceName()))
			damage := combatLogEntry.GetValue()
			// damage should be prob rescaled based on its type?
			// fmt.Println(m.GetDamageType())
			// fmt.Println(m.GetDamageCategory())
			if _, ok := matchData.heroDamageMap[attacker]; ok {
				matchData.heroDamageMap[attacker] += damage
			} else {
				matchData.heroDamageMap[attacker] = damage
			}
			if _, ok := matchData.damageTakenMap[target]; ok {
				matchData.damageTakenMap[target] += damage
			} else {
				matchData.damageTakenMap[target] = damage
			}
		} else if (combatLogEntry.GetIsAttackerHero() || combatLogEntry.GetIsAttackerIllusion()) && combatLogEntry.GetIsTargetBuilding() {
			attacker, _ := matchData.parser.LookupStringByIndex("CombatLogNames", int32(combatLogEntry.GetDamageSourceName()))
			damage := combatLogEntry.GetValue()
			if _, ok := matchData.towerDamageMap[attacker]; ok {
				matchData.towerDamageMap[attacker] += damage
			} else {
				matchData.towerDamageMap[attacker] = damage
			}
		}
	}
	return nil
}
