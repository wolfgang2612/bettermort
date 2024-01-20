import secrets
import json
import boto3
from datetime import datetime, timedelta

from constants import DB_CONSTANTS, LOBBY_CONSTANTS
from util.params import PARAMS_UTIL


client = boto3.client("dynamodb")


def get_unique_code():
    retries = 0
    while True:
        if retries >= LOBBY_CONSTANTS.MAX_CODE_RETRIES:
            raise Exception("Unable to create unique lobby.")

        lobby_code = secrets.token_hex(LOBBY_CONSTANTS.LOBBY_CODE_NBYTES)
        response = client.get_item(
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            TableName=DB_CONSTANTS.DYNAMODB_TABLE_NAME,
        )

        if not "Item" in response:
            break

        retries += 1

    return lobby_code


def create_lobby_code(args):
    PARAMS_UTIL.validate_inputs(args)

    lobby_leader = args["lobby_leader"]
    connection_id = args["connection_id"]

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
                            "connection_id": {"S": connection_id},
                        }
                    }
                ]
            },
            "lobby_leader": {
                "S": lobby_leader,
            },
            "time_to_live": {
                "N": f"{int((datetime.now() + timedelta(days=DB_CONSTANTS.TTL_DAYS)).timestamp())}"
            },
        },
        TableName=DB_CONSTANTS.DYNAMODB_TABLE_NAME,
    )

    return lobby_code


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        body = json.loads(event["body"])
        lobby_leader = body.get("player_name", "")

        return_body["lobby_code"] = create_lobby_code(
            {
                "lobby_leader": lobby_leader,
                "connection_id": event["requestContext"]["connectionId"],
            }
        )
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
