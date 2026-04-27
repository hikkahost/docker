# -------------------------------
# Используем образ python:3.14-slim как базовый для этапа сборки
FROM python:3.14-slim AS builder
# Отключаем кэширование pip, чтобы уменьшить размер образа
ENV PIP_NO_CACHE_DIR=1
# Устанавливаем необходимые пакеты для сборки Python пакетов и git
RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends git build-essential
# Очищаем кэш apt для уменьшения размера образа
RUN rm -rf /var/lib/apt/lists/ /var/cache/apt/archives/ /tmp/*
# Клонируем репозиторий
RUN git clone https://github.com/coddrago/Heroku /Heroku
# Создаем виртуальное окружение Python
RUN python -m venv /venv
# Обновляем инструменты сборки wheels для pyproject-пакетов
RUN /venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel
# Устанавливаем зависимости проекта
RUN /venv/bin/pip install --no-warn-script-location --no-cache-dir -r /Heroku/requirements.txt

# -------------------------------
# Используем другой базовый образ для финального контейнера
FROM python:3.14-slim
# Устанавливаем необходимые пакеты для работы приложения
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    curl libcairo2 git ffmpeg libmagic1 \
    libavcodec-dev libavutil-dev libavformat-dev \
    libswscale-dev libavdevice-dev gcc
# Устанавливаем Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm nodesource_setup.sh
# Очищаем кэш apt для уменьшения размера образа
RUN rm -rf /var/lib/apt/lists/ /var/cache/apt/archives/ /tmp/*
# Устанавливаем переменные окружения для работы приложения
ENV DOCKER=true \
    HIKKAHOST=true \
    GIT_PYTHON_REFRESH=quiet \
    PIP_NO_CACHE_DIR=1
# Копируем собранное приложение и виртуальное окружение из этапа сборки
COPY --from=builder /Heroku /Heroku
COPY --from=builder /venv /venv
# Привязываем python/pip и python3/pip3 к venv
RUN ln -sf /venv/bin/python /usr/local/bin/python && \
    ln -sf /venv/bin/python /usr/local/bin/python3 && \
    ln -sf /venv/bin/pip /usr/local/bin/pip && \
    ln -sf /venv/bin/pip /usr/local/bin/pip3
# Устанавливаем рабочую директорию
WORKDIR /Heroku
# Открываем порт 8080 для доступа к приложению
EXPOSE 8080

# Определяем команду запуска приложения
CMD ["python3", "-m", "heroku"]