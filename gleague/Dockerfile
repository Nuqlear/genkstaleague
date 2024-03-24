FROM python:3.6
RUN apt-get update
RUN apt-get install -f -y postgresql-client
RUN apt-get install -y libjpeg-dev zlib1g-dev

COPY gleague/ /gleague/
COPY tests/ /tests/
COPY alembic/ /alembic/
COPY cli.py requirements.txt alembic.ini wsgi.py /
WORKDIR /
RUN pip install -r requirements.txt
EXPOSE 5000
