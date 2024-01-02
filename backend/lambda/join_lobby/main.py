import json
import boto3

from constants import DB, LOBBY
from util.db import validate_lobby_exists
from util.lobby import serialize_player_list

client = boto3.client("dynamodb")


def validate_inputs(lobby_code, player_name):
    if lobby_code == "" or player_name == "":
        raise Exception("Invalid inputs.")

    return validate_lobby_exists(lobby_code)


def register_player(args):
    lobby_code = args["lobby_code"]
    player_name = args["player_name"]

    response = validate_inputs(lobby_code, player_name)

    player_list = []
    if "player_list" in response["Item"]:
        player_list = response["Item"]["player_list"]["L"]

    if len(player_list) >= LOBBY.MAX_PLAYERS:
        raise Exception(f"A maximum of {LOBBY.MAX_PLAYERS} players are allowed.")

    if not any(player["M"]["player"]["S"] == player_name for player in player_list):
        player_list.append(
            {
                "M": {
                    "player": {"S": player_name},
                    "faction": {"S": ""},
                    "role": {"S": ""},
                }
            }
        )

        response = client.update_item(
            TableName=DB.DYNAMODB_TABLE_NAME,
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            UpdateExpression="set player_list = :player_list",
            ExpressionAttributeValues={":player_list": {"L": player_list}},
        )

    else:
        raise Exception("Duplicate player name.")

    return serialize_player_list(player_list)


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        body = json.loads(event["body"])
        lobby_code = body.get("lobby_code", "")
        player_name = body.get("player_name", "")

        return_body["player_list"] = register_player(
            {
                "lobby_code": lobby_code,
                "player_name": player_name,
            }
        )
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
