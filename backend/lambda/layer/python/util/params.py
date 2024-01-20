class PARAMS_UTIL:
    def serialize_player_list(player_list):
        return [player["M"]["player"]["S"] for player in player_list]

    def validate_inputs(args):
        for key in args:
            if args[key] == "":
                raise Exception("Invalid inputs.")
