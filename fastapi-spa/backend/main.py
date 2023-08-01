from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI

app = FastAPI()


@app.get('/api/echo')
async def echo(msg: str):
  return msg


class SPA(StaticFiles):

  async def get_response(self, path: str, scope):
    response = await super().get_response(path, scope)

    if response.status_code == 404:
      response = await super().get_response('.', scope)

    return response


app.mount('/', SPA(directory='./frontend/dist', html=True))
