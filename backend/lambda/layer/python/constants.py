class DB_CONSTANTS:
    DYNAMODB_TABLE_NAME = "bettermort"
    TTL_DAYS = 1


class LOBBY_CONSTANTS:
    LOBBY_CODE_NBYTES = 3
    MIN_PLAYERS = 5
    MAX_PLAYERS = 10
    MAX_CODE_RETRIES = 10


class API_CONSTANTS:
    API_ID = "biogsv1mjj"
    STAGE = "prod"
    AWS_REGION = "ap-south-1"
    ENDPOINT_URL = f"https://{API_ID}.execute-api.{AWS_REGION}.amazonaws.com/{STAGE}"
