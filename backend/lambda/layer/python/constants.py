class DB:
    DYNAMODB_TABLE_NAME = "bettermort"
    TTL_DAYS = 1


class LOBBY:
    LOBBY_CODE_NBYTES = 3
    MIN_PLAYERS = 5
    MAX_PLAYERS = 10
    MAX_CODE_RETRIES = 10
