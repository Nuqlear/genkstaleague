package main

import (
    "strconv"
    "encoding/json"

    "github.com/dotabuff/manta"
    "github.com/dotabuff/manta/dota"
)


type MatchPlayerData struct {
    AccountId uint64 `json:"account_id"`
    AccountIdOrig uint64 `json:"account_id_orig"`
    HeroId int32 `json:"hero_id"`
    HeroName string `json:"hero_name"`
    Kills int32 `json:"kills"`
    Deaths int32 `json:"deaths"`
    Assists int32 `json:"assists"`
    LastHits int32 `json:"last_hits"`
    Denies int32 `json:"denies"`
    Level int32 `json:"level"`
    PlayerSlot int `json:"player_slot"`
    GoldPerMin int32 `json:"gold_per_min"`
    XpPerMin int32 `json:"xp_per_min"`
    HeroDamage uint32 `json:"hero_damage"`
    DamageTaken uint32 `json:"damage_taken"`
    TowerDamage uint32 `json:"tower_damage"`
}

type MatchData struct {
    MatchId uint32 `json:"match_id"`
    GameMode int32 `json:"game_mode"`
    StartTime uint32 `json:"start_time"`
    EndTime uint32 `json:"end_time"`
    Duration float32 `json:"duration"`
    RadiantWin bool `json:"radiant_win"`
    Players [10]MatchPlayerData `json:"players"`
}



func (matchData *MatchData) TryToUpdatePlayersData(pe *manta.PacketEntity) {
    count := 0
    if pe.ClassName == "CDOTA_PlayerResource" {
        for count < 10 {
            matchPlayerData := matchData.Players[count]
            if count > 4 {
                matchPlayerData.PlayerSlot = count + 123          
            } else {
                matchPlayerData.PlayerSlot = count
            }
            fetchFrom := "m_vecPlayerData.000" + strconv.Itoa(count)
            if result, ok := pe.FetchUint64(fetchFrom + ".m_iPlayerSteamID"); ok && matchPlayerData.AccountId == 0 {
                matchPlayerData.AccountIdOrig = result
                // format account_id to match Web API version
                matchPlayerData.AccountId, _ = strconv.ParseUint(strconv.Itoa(int(result))[3:], 10, 64)
                matchPlayerData.AccountId -= 61197960265728
            }
            fetchFrom = "m_vecPlayerTeamData.000" + strconv.Itoa(count)
            if result, ok := pe.FetchInt32(fetchFrom + ".m_nSelectedHeroID"); ok {
                matchPlayerData.HeroId = result
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iKills"); ok {
                matchPlayerData.Kills = result            
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iDeaths"); ok {
                matchPlayerData.Deaths = result            
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iAssists"); ok {
                matchPlayerData.Assists = result            
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iLevel"); ok {
                matchPlayerData.Level = result
            }
            matchData.Players[count] = matchPlayerData
            count++
        }
    }
    if pe.ClassName == "CDOTA_DataRadiant" || pe.ClassName == "CDOTA_DataDire" {
        for count < 5 {
            realCount := count
            if pe.ClassName == "CDOTA_DataDire" {
                realCount += 5
            }
            matchPlayerData := matchData.Players[realCount]
            fetchFrom := "m_vecDataTeam.000" + strconv.Itoa(count)
            duration := int32(matchData.Duration/60)
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iTotalEarnedGold"); ok && duration != 0 {
                matchPlayerData.GoldPerMin = result/duration
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iTotalEarnedXP"); ok && duration != 0 {
                matchPlayerData.XpPerMin = result/duration
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iDenyCount"); ok {
                matchPlayerData.Denies = result
            }
            if result, ok := pe.FetchInt32(fetchFrom + ".m_iLastHitCount"); ok {
                matchPlayerData.LastHits = result
            }
            matchData.Players[realCount] = matchPlayerData
            count++
        }
    }
}

func ParseFromFile(path string) string {
    p, _ := manta.NewParserFromFile(path)
    return ParseDemo(p)
}

func ParseFromRawData(buf []byte) string {
    p, _ := manta.NewParser(buf)
    return ParseDemo(p)
}

func ParseDemo(p* manta.Parser) string {
    var matchData = MatchData{}
    var gameEndTime, gameStartTime float32

    // get some match data from DemoFileInfo
    p.Callbacks.OnCDemoFileInfo(func(m *dota.CDemoFileInfo) error {
        gameInfo := m.GetGameInfo().GetDota()
        matchData.MatchId = gameInfo.GetMatchId()
        matchData.GameMode = gameInfo.GetGameMode()
        matchData.RadiantWin = (gameInfo.GetGameWinner() == 2)
        matchData.StartTime = gameInfo.GetEndTime()
        matchData.EndTime = gameInfo.GetEndTime()
        return nil
    })

    p.OnPacketEntity(func(pe *manta.PacketEntity, pet manta.EntityEventType) error {
        // calculating game duration
        if pe.ClassName == "CDOTAGamerulesProxy" {
            gameEndTime, _ = pe.FetchFloat32("CDOTAGamerules.m_flGameEndTime")
            gameStartTime, _ = pe.FetchFloat32("CDOTAGamerules.m_flGameStartTime")
            matchData.Duration = gameEndTime - gameStartTime
        }
        // updating players data
        matchData.TryToUpdatePlayersData(pe)
        return nil
    })

    // calculating hero damage, damage taken and tower damage
    var heroDamageMap = make(map[string]uint32)
    var towerDamageMap = make(map[string]uint32)
    var damageTakenMap = make(map[string]uint32)
    p.Callbacks.OnCMsgDOTACombatLogEntry(func(m *dota.CMsgDOTACombatLogEntry) error {
        t := m.GetType()
        switch dota.DOTA_COMBATLOG_TYPES(t) {
        case dota.DOTA_COMBATLOG_TYPES_DOTA_COMBATLOG_DAMAGE:
            if m.GetIsAttackerHero() && m.GetIsTargetHero() && !m.GetIsTargetIllusion() {
                attacker, _ := p.LookupStringByIndex("CombatLogNames", int32(m.GetDamageSourceName()))
                target, _ := p.LookupStringByIndex("CombatLogNames", int32(m.GetTargetSourceName()))
                damage := m.GetValue()
                // damage should be prob rescaled based on its type?
                // but .GetDamageType/.GetDamageCategory always returns zero
                if _, ok := heroDamageMap[attacker]; ok {
                    heroDamageMap[attacker] += damage
                } else {
                    heroDamageMap[attacker] = damage
                }

                if _, ok := damageTakenMap[target]; ok {
                    damageTakenMap[target] += damage
                } else {
                    damageTakenMap[target] = damage
                }
            } else if m.GetIsAttackerHero() && m.GetIsTargetBuilding() {
                attacker, _ := p.LookupStringByIndex("CombatLogNames", int32(m.GetDamageSourceName()))
                damage := m.GetValue()
                if _, ok := towerDamageMap[attacker]; ok {
                    towerDamageMap[attacker] += damage
                } else {
                    towerDamageMap[attacker] = damage
                }        
            }
        }
        return nil
    })

    p.Start()

    // set MatchData.players hero_name, hero_damage, damage_taken, tower_damage
    for index, player := range matchData.Players {
        // heroesMap declared in heroes.go
        heroName := heroesMap[player.HeroId]
        matchData.Players[index].HeroName = heroName

        if val, ok := heroDamageMap[heroName]; ok {
            matchData.Players[index].HeroDamage = val            
        } else {
            matchData.Players[index].HeroDamage = 0
        }

        if val, ok := damageTakenMap[heroName]; ok {
            matchData.Players[index].DamageTaken = val            
        } else {
            matchData.Players[index].DamageTaken = 0
        }

        if val, ok := towerDamageMap[heroName]; ok {
            matchData.Players[index].TowerDamage = val            
        } else {
            matchData.Players[index].TowerDamage = 0
        }
    }

    jsonOutput, _ := json.Marshal(map[string]MatchData{"result":matchData})
    return string(jsonOutput)
}
