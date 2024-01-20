import json
import boto3

from constants import DB_CONSTANTS, LOBBY_CONSTANTS
from util.lobby import LOBBY_UTIL
from util.params import PARAMS_UTIL

client = boto3.client("dynamodb")


def register_player(args):
    PARAMS_UTIL.validate_inputs(args)

    lobby_code = args["lobby_code"]
    player_name = args["player_name"]
    connection_id = args["connection_id"]

    response = LOBBY_UTIL.get_lobby_data(lobby_code)

    player_list = []
    if "player_list" in response["Item"]:
        player_list = response["Item"]["player_list"]["L"]

    if len(player_list) >= LOBBY_CONSTANTS.MAX_PLAYERS:
        raise Exception(
            f"A maximum of {LOBBY_CONSTANTS.MAX_PLAYERS} players are allowed."
        )

    if not any(
        player.get("M", {}).get("player", {}).get("S") == player_name
        for player in player_list
    ):
        player_list.append(
            {
                "M": {
                    "player": {"S": player_name},
                    "faction": {"S": ""},
                    "role": {"S": ""},
                    "connection_id": {"S": connection_id},
                }
            }
        )

        client.update_item(
            TableName=DB_CONSTANTS.DYNAMODB_TABLE_NAME,
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

    return PARAMS_UTIL.serialize_player_list(player_list)


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
                "connection_id": event["requestContext"]["connectionId"],
            }
        )

    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
