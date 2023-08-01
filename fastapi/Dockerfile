FROM python:3.9-slim
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN pip install -r ./requirements.txt
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
