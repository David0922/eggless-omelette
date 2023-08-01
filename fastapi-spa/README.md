### build

frontend

```
cd ./frontend
yarn
yarn build
```

backend

```
pip install -r ./backend/requirements.txt
```

### run

```
uvicorn backend.main:app --host 0.0.0.0 --port 8080 --reload
```
