import json
import boto3

from constants import DB
from util.db import validate_lobby_exists
from util.lobby import serialize_player_list

client = boto3.client("dynamodb")


def kick_player(args):
    lobby_code = args["lobby_code"]
    player_to_kick = args["player_to_kick"]

    response = validate_lobby_exists(lobby_code)

    player_list = response["Item"]["player_list"]["L"]

    player_index = next(
        (
            index
            for index, item in enumerate(player_list)
            if item["M"]["player"]["S"] == player_to_kick
        ),
        None,
    )

    if player_index is None:
        raise Exception("Player not found.")

    player_list.pop(player_index)

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

    return serialize_player_list(player_list)


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        body = json.loads(event["body"])
        lobby_code = body.get("lobby_code", "")
        player_to_kick = body.get("player_name", "")

        return_body["player_list"] = kick_player(
            {
                "lobby_code": lobby_code,
                "player_to_kick": player_to_kick,
            }
        )
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
