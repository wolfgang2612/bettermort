def serialize_player_list(player_list):
    return [player["M"]["player"]["S"] for player in player_list]
