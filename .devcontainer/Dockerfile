FROM registry.fedoraproject.org/f33/fedora-toolbox:33

RUN dnf install -y python python-devel && \
    python -m pip install \
        autopep8 \
        pycodestyle \
        pylint \
        pytest \
        jsonlint \
        yamllint \
        rstcheck \
        flake8 \
        requests

RUN groupadd filbot && \
    useradd -g filbot filbot

RUN echo "%filbot ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/filbot.sudo && \
    chmod 440 /etc/sudoers.d/filbot.sudo

USER filbot
WORKDIR /home/filbot

CMD ["/bin/bash"]