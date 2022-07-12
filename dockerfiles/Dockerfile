FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=US/Eastern
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8

# display setup
ENV DISPLAY=:1
ENV GEOMETRY=1920x1200
ENV DEPTH=32
EXPOSE 5901

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezon && \
    apt-get update -yq && \
    apt-get install -yq wget curl build-essential x11-apps git vim bash-completion \
                        python3 python3-venv python3-pip python3-dev libpython3-dev \
                        xterm tigervnc-standalone-server libxrender-dev xfce4 xfce4-goodies && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update -yq && apt-get install -yq nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

# setup and change to user
ARG USER=lava
RUN useradd -rm -p "$(openssl passwd -6 lava)" -d /home/${USER} -s /bin/bash -G root -G sudo -u 1000 ${USER}

# setup poetry virtual environment path
ENV VENV_PATH=/python_env/lava_env
ENV POETRY_HOME="/opt/poetry" \
    POETRY_CACHE_DIR="/opt/poetry/.cache"
RUN mkdir -p ${VENV_PATH} && chown ${USER}:${USER} ${VENV_PATH} && \
    mkdir -p ${POETRY_HOME} && chmod 777 -R ${POETRY_HOME}

USER ${USER}
SHELL ["/bin/bash", "-c"]
RUN python -m venv ${VENV_PATH} && \
    ${VENV_PATH}/bin/pip install --no-cache-dir -U pip setuptools wheel && \
    ${VENV_PATH}/bin/pip install --no-cache-dir poetry
USER root
RUN ${VENV_PATH}/bin/poetry completions bash > /etc/bash_completion.d/poetry
USER ${USER}

WORKDIR /home/${USER}

# install lava-nc from source
RUN source ${VENV_PATH}/bin/activate && \
    git clone --recursive https://github.com/lava-nc/lava.git && \
    cd lava && poetry install

# install and build lava-docs from source
RUN source ${VENV_PATH}/bin/activate && \
    git clone --recursive https://github.com/lava-nc/lava-docs.git && \
    cd lava-docs && poetry install && \
    sed -i 's/python/#python/g' Makefile && \
    make html

# install lava-dl from source
RUN source ${VENV_PATH}/bin/activate && \
    git clone --recursive https://github.com/lava-nc/lava-dl.git && \
    cd lava-dl && poetry install

# install lava-dnf from source
RUN source ${VENV_PATH}/bin/activate && \
    git clone --recursive --single-branch -b add_poetry https://github.com/lava-nc/lava-dnf.git && \
    cd lava-dnf && poetry install

# install lava-optimization from source
RUN source ${VENV_PATH}/bin/activate && \
    git clone --recursive https://github.com/lava-nc/lava-optimization.git && \
    cd lava-optimization && \
    sed -i 's/lava-nc/#lava-nc/g' requirements.txt && \
    pip install --no-cache-dir .

# install custom python packages
COPY ./requirements.txt /
RUN source ${VENV_PATH}/bin/activate && \
    pip install --no-cache-dir -r /requirements.txt --extra-index-url https://download.pytorch.org/whl/cu116 && \
    jupyter lab build

# setup entrypoint and cmd
COPY ./entrypoint.sh ./start_vnc.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start_vnc.sh"]
