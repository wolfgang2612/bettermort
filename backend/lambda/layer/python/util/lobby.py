import boto3
from constants import DB_CONSTANTS

client = boto3.client("dynamodb")


class LOBBY_UTIL:
    def get_lobby_data(lobby_code):
        response = client.get_item(
            Key={
                "lobby_code": {
                    "S": lobby_code,
                }
            },
            TableName=DB_CONSTANTS.DYNAMODB_TABLE_NAME,
        )

        if not "Item" in response:
            raise Exception("Lobby not found.")

        return response
