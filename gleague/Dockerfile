FROM python:3.6
RUN apt-get update
RUN apt-get install -f -y postgresql-client

# install bower
RUN apt-get install -y -qq npm
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install --global bower

COPY gleague/ /gleague/
WORKDIR /gleague/frontend/static/lib
RUN bower install --allow-root
COPY tests/ /tests/
COPY alembic/ /alembic/
COPY cli.py requirements.txt alembic.ini wsgi.py /
WORKDIR /
RUN pip install -r requirements.txt
EXPOSE 5000
