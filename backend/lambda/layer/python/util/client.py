import boto3
import json

from constants import API_CONSTANTS

client = boto3.client(
    "apigatewaymanagementapi", endpoint_url=API_CONSTANTS.ENDPOINT_URL
)


class CLIENT_UTIL:
    def post_data_to_client(data, connection_id):
        return client.post_to_connection(
            Data=json.dumps(data), ConnectionId=connection_id
        )
