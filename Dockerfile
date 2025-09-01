ARG PYTHON_VERSION=3.12

FROM python:$PYTHON_VERSION-slim AS build

ENV PYTHONUNBUFFERED=1

WORKDIR /code

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl unzip gcc python3-dev libpq-dev libmariadb-dev \
    && curl -L https://github.com/Gozargah/Marzban-scripts/raw/master/install_latest_xray.sh | bash \
    && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /code/
RUN python3 -m pip install --upgrade pip setuptools \
    && pip install --no-cache-dir --upgrade -r /code/requirements.txt \
    && pip install --no-cache-dir mysqlclient

FROM python:$PYTHON_VERSION-slim

ENV PYTHON_LIB_PATH=/usr/local/lib/python${PYTHON_VERSION%.*}/site-packages
WORKDIR /code

# Install MySQL client libraries for runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmariadb3 curl \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf $PYTHON_LIB_PATH/*

COPY --from=build $PYTHON_LIB_PATH $PYTHON_LIB_PATH
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/share/xray /usr/local/share/xray

COPY . /code

# Create necessary directories
RUN mkdir -p /var/lib/marzban /opt/marzban

RUN ln -s /code/marzban-cli.py /usr/bin/marzban-cli \
    && chmod +x /usr/bin/marzban-cli \
    && marzban-cli completion install --shell bash \
    && chmod +x /code/healthcheck.sh

# Create startup script
RUN echo '#!/bin/bash\n\
# Wait for database to be ready\n\
echo "Waiting for database to be ready..."\n\
sleep 10\n\
\n\
# Run database migrations\n\
echo "Running database migrations..."\n\
alembic upgrade head\n\
\n\
# Create admin user if not exists\n\
echo "Creating admin user..."\n\
marzban-cli admin create --sudo --username admin --password admin || echo "Admin user already exists"\n\
\n\
# Start the application\n\
echo "Starting Marzban..."\n\
python main.py' > /code/start.sh \
    && chmod +x /code/start.sh

EXPOSE 8000

CMD ["/code/start.sh"]
