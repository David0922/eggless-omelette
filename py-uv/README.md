## install dependencies

```bash
uv sync
```

## add dependencies

```bash
# prod dependencies
uv add PACKAGES

# dev dependencies
uv add --dev PACKAGES
```

## import dependencies from requirements.txt

```bash
uv add --requirements requirements.txt
```

## format

```bash
uv run isort .
uv run yapf --in-place --recursive . --parallel
```

## run

```bash
uv run --module server.main

# or
uv sync
source ./.venv/bin/activate
python -m server.main
```

## clean

```bash
rm -rf ./.venv ./dist

uv cache clean
rm -r "$(uv python dir)"
rm -r "$(uv tool dir)"
```
