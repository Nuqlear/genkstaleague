

def get_human_readable_hero_name(hero_name: str) -> str:
    overwrite_map = {
        "nevermore": "Shadow Fiend",
        "vengefulspirit": "Vengeful Spirit",
        "windrunner": "Windranger",
        "zuus": "Zeus",
        "necrolyte": "Necrophos",
        "queenofpain": "Queen Of Pain",
        "skeleton_king": "Wraith King",
        "rattletrap": "Clockwerk",
        "obsidian_destroyer": "Outworld Destroyer",
        "treant": "Treant Protector",
        "magnataur": "Magnus",
        "shredder": "Timbersaw",
        "abyssal_underlord": "Underlord",
    }
    if hero_name in overwrite_map:
        return overwrite_map[hero_name]
    return ' '.join([part.capitalize() for part in hero_name.split('_')])
