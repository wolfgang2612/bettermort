import secrets
import json
import boto3
from datetime import datetime, timedelta


table_name = "bettermort"
lobby_code_nbytes = 3
time_to_live_days = 1

client = boto3.client("dynamodb")


def create_lobby_code():
    retries = 0
    max_retries = 10
    while True:
        if retries >= max_retries:
            raise Exception("Unable to create unique lobby.")

        lobby_code = secrets.token_hex(lobby_code_nbytes)
        response = client.get_item(
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            TableName=table_name,
        )

        if not "Item" in response:
            break

        retries += 1

    client.put_item(
        Item={
            "lobby_code": {
                "S": lobby_code,
            },
            "time_to_live": {
                "N": f"{int((datetime.now() + timedelta(days=time_to_live_days)).timestamp())}"
            },
        },
        TableName=table_name,
    )

    return lobby_code


def handler(event, context):
    return_code = 200
    return_body = {"status": "success"}

    try:
        return_body["lobby_code"] = create_lobby_code()
    except Exception as e:
        return_code = 500
        return_body = {"status": "error", "message": str(e)}

    return {"statusCode": return_code, "body": json.dumps(return_body)}
