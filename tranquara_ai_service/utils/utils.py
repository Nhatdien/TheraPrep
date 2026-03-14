from models.user import UserInformations
import requests
import os


def get_user_information(token: str) -> requests.Response:
    core_service_url = os.getenv("CORE_SERVICE_URL", "http://core_service:4000")
    return requests.get(f"{core_service_url}/user_information", headers={
        "Authorization": token
    })
