import secrets
import json
import boto3
from datetime import datetime, timedelta

from constants import DB, LOBBY


client = boto3.client("dynamodb")


def get_unique_code():
    retries = 0
    while True:
        if retries >= LOBBY.MAX_CODE_RETRIES:
            raise Exception("Unable to create unique lobby.")

        lobby_code = secrets.token_hex(LOBBY.LOBBY_CODE_NBYTES)
        response = client.get_item(
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            TableName=DB.DYNAMODB_TABLE_NAME,
        )

        if not "Item" in response:
            break

        retries += 1

    return lobby_code


def create_lobby_code(args):
    lobby_leader = args["lobby_leader"]
    if not lobby_leader:
        raise Exception("Player name empty.")
    lobby_code = get_unique_code()

    client.put_item(
        Item={
            "lobby_code": {
                "S": lobby_code,
            },
            "player_list": {
                "L": [
                    {
                        "M": {
                            "player": {"S": lobby_leader},
                            "role": {"S": ""},
                            "faction": {"S": ""},
                        }
                    }
                ]
            },
            "lobby_leader": {
                "S": lobby_leader,
            },
            "time_to_live": {
                "N": f"{int((datetime.now() + timedelta(days=DB.TTL_DAYS)).timestamp())}"
            },
        },
        TableName=DB.DYNAMODB_TABLE_NAME,
    )

    return lobby_code


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        body = json.loads(event["body"])
        lobby_leader = body.get("player_name", "")

        return_body["lobby_code"] = create_lobby_code({"lobby_leader": lobby_leader})
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
