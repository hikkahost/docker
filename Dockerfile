FROM python:3.10-slim-buster as main
ENV DOCKER=true
ENV HIKKAHOST=true
ENV rate=basic
ENV GIT_PYTHON_REFRESH=quiet
ENV PIP_NO_CACHE_DIR=1
RUN apt update && apt install libcairo2 git -y --no-install-recommends
RUN apt-get install gcc python3-dev -y --no-install-recommends
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp/*
RUN git clone https://github.com/hikariatama/Hikka /Hikka
WORKDIR /Hikka
RUN pip install --no-warn-script-location --no-cache-dir -r requirements.txt
EXPOSE 8080
RUN mkdir /data
CMD ["python3", "-m", "hikka"]
