# Dockerfile from https://github.com/python-poetry/poetry/discussions/1879
# `python-base` sets up all our shared environment variables
FROM python:3.9.5-slim as python-base
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc as files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.6.1 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    # Hikka
    DOCKER=true \
    GIT_PYTHON_REFRESH=quiet \
    HIKKAHOST=true

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# required for git clone
RUN apt update && apt upgrade -y && apt install git -y

# clone hikka
RUN git clone https://github.com/hikariatama/Hikka -b v1.6.4

# dependencies for building poetry
FROM python-base as builder-base
RUN apt update && apt upgrade -y && apt install \
    curl \
    build-essential -y

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python -

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY --from=python-base Hikka/poetry.lock Hikka/pyproject.toml ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# `production` image used for runtime
FROM python-base as production
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

# deps for hikka
RUN apt update && apt upgrade -y && apt install \
    curl \
    git \
    libmagic1 \
    neofetch -y --fix-missing --no-install-recommends

RUN mkdir /data && cd /data
WORKDIR /data/Hikka
COPY --from=builder-base /Hikka .

EXPOSE 8080

CMD python -m hikka --port 8080 --root
