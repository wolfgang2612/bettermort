import boto3

from constants import DB

client = boto3.client("dynamodb")


def validate_lobby_exists(lobby_code):
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

    return response
