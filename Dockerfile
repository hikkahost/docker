FROM python:3.8-slim-buster as builder

ENV PIP_NO_CACHE_DIR=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl libcairo2 git ffmpeg \
    libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libavdevice-dev neofetch wkhtmltopdf gcc python3-dev

RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs wget
RUN rm -rf /var/lib/apt/lists/ /var/cache/apt/archives/ /tmp/*

RUN git clone https://github.com/hikariatama/Hikka /Hikka
RUN python -m venv /venv
RUN /venv/bin/pip install --no-warn-script-location --no-cache-dir -r /Hikka/requirements.txt

FROM python:3.8-slim-buster

ENV DOCKER=true \
    HIKKAHOST=true \
    rate=basic \
    GIT_PYTHON_REFRESH=quiet \
    PIP_NO_CACHE_DIR=1

COPY --from=builder /Hikka /Hikka
COPY --from=builder /venv /Hikka/venv

WORKDIR /Hikka
EXPOSE 8080
CMD ["python3", "-m", "hikka"]

