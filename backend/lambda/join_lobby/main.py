import json
import boto3

from constants import DB

client = boto3.client("dynamodb")


def validate_inputs(lobby_code, player_name):
    if lobby_code == "" or player_name == "":
        return False

    return True


def register_player(lobby_code, player_name):
    if not validate_inputs(lobby_code, player_name):
        raise Exception("Invalid inputs.")

    response = client.get_item(
        Key={
            "lobby_code": {
                "S": lobby_code,
            }
        },
        TableName=DB.DYNAMODB_TABLE_NAME,
    )

    if not "Item" in response:
        raise Exception("Lobby not found.")

    player_list = []
    if "player_list" in response["Item"]:
        player_list = response["Item"]["player_list"]["SS"]

    if not player_name in player_list:
        player_list.append(player_name)

        response = client.update_item(
            TableName=DB.DYNAMODB_TABLE_NAME,
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            UpdateExpression="set player_list = :player_list",
            ExpressionAttributeValues={":player_list": {"SS": player_list}},
        )

    else:
        raise Exception("Duplicate player name.")

    return player_list


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        body = json.loads(event["body"])
        lobby_code = body.get("lobby_code", "")
        player_name = body.get("player_name", "")

        return_body["player_list"] = register_player(lobby_code, player_name)
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
