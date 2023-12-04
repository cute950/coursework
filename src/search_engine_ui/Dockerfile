FROM python:3.6-alpine
WORKDIR /ui
COPY requirements.txt /ui
RUN pip install -r requirements.txt
COPY ./ui /ui
ENV MONGO mongodb
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py
EXPOSE 8000
ENTRYPOINT [ "gunicorn", "ui:app", "-b", "0.0.0.0" ]
