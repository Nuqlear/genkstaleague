package main

import (
    "strconv"

    "github.com/dotabuff/manta"
    "github.com/dotabuff/manta/dota"
    "github.com/davecgh/go-spew/spew"
)


type MatchPlayerData struct {
    account_id uint64
    hero_id int32
    kills, deaths, assists int32
    last_hits, denies int32
    level int32
    player_slot int
    gold_per_min int32
    xp_per_min int32
    hero_damage int32
    tower_damage int32
}

type MatchData struct {
    match_id uint32
    game_mode int32
    start_time, end_time uint32
    duration float32
    radian_win bool
    players [10]MatchPlayerData
}


func (matchData *MatchData) TryToUpdatePlayersData(pe *manta.PacketEntity) {
    count := 0
    if pe.ClassName == "CDOTA_PlayerResource" {
        for count < 10 {
            matchPlayerData := matchData.players[count]
            if count > 4 {
                matchPlayerData.player_slot = count + 123          
            } else {
                matchPlayerData.player_slot = count
            }
            fetch_from := "m_vecPlayerData.000" + strconv.Itoa(count)
            if result, ok := pe.FetchUint64(fetch_from + ".m_iPlayerSteamID"); ok && matchPlayerData.account_id == 0 {
                // format account_id to match Web API version
                matchPlayerData.account_id, _ = strconv.ParseUint(strconv.Itoa(int(result))[3:], 10, 64)
                matchPlayerData.account_id -= 61197960265728
            }
            fetch_from = "m_vecPlayerTeamData.000" + strconv.Itoa(count)
            if result, ok := pe.FetchInt32(fetch_from + ".m_nSelectedHeroID"); ok {
                matchPlayerData.hero_id = result
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iKills"); ok {
                matchPlayerData.kills = result            
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iDeaths"); ok {
                matchPlayerData.deaths = result            
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iAssists"); ok {
                matchPlayerData.assists = result            
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iLevel"); ok {
                matchPlayerData.level = result
            }
            matchData.players[count] = matchPlayerData
            count++
        }
    }
    if pe.ClassName == "CDOTA_DataRadiant" || pe.ClassName == "CDOTA_DataDire" {
        for count < 5 {
            real_count := count
            if pe.ClassName == "CDOTA_DataDire" {
                real_count += 5
            }
            matchPlayerData := matchData.players[real_count]
            fetch_from := "m_vecDataTeam.000" + strconv.Itoa(count)
            duration := int32(matchData.duration/60)
            if result, ok := pe.FetchInt32(fetch_from + ".m_iTotalEarnedGold"); ok && duration != 0 {
                matchPlayerData.gold_per_min = result/duration
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iTotalEarnedXP"); ok && duration != 0 {
                matchPlayerData.xp_per_min = result/duration
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iDenyCount"); ok {
                matchPlayerData.denies = result
            }
            if result, ok := pe.FetchInt32(fetch_from + ".m_iLastHitCount"); ok {
                matchPlayerData.last_hits = result
            }
            matchData.players[real_count] = matchPlayerData
            count++
        }
    }
}

func main() {
    p, _ := manta.NewParserFromFile("/Users/nuqlya/1948506460.dem")

    var matchData = MatchData{}
    var gameEndTime, gameStartTime float32

    // get some match data from DemoFileInfo
    p.Callbacks.OnCDemoFileInfo(func(m *dota.CDemoFileInfo) error {
        game_info := m.GetGameInfo().GetDota()
        matchData.match_id = game_info.GetMatchId()
        matchData.game_mode = game_info.GetGameMode()
        matchData.radian_win = (game_info.GetGameWinner() == 2)
        matchData.start_time = game_info.GetEndTime()
        matchData.end_time = game_info.GetEndTime()
        return nil
    })

    p.OnPacketEntity(func(pe *manta.PacketEntity, pet manta.EntityEventType) error {
        // calculating game duration
        if pe.ClassName == "CDOTAGamerulesProxy" {
            gameEndTime, _ = pe.FetchFloat32("CDOTAGamerules.m_flGameEndTime")
            gameStartTime, _ = pe.FetchFloat32("CDOTAGamerules.m_flGameStartTime")
            matchData.duration = gameEndTime-gameStartTime
        }
        // updating players data
        matchData.TryToUpdatePlayersData(pe)
        return nil
    })

    p.Start()

    spew.Dump(matchData)
}