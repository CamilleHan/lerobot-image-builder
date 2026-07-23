FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV MUJOCO_GL=egl
ENV PYOPENGL_PLATFORM=egl

# LIBERO、MuJoCo、OpenCV、视频处理和源码编译所需系统库
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    ffmpeg \
    git \
    openssh-server \
    openssh-client \
    libegl1 \
    libgl1 \
    libglew2.2 \
    libglib2.0-0 \
    libglfw3 \
    libglvnd0 \
    libgomp1 \
    libosmesa6 \
    libsm6 \
    libusb-1.0-0 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    pkg-config \
    wget \
    && mkdir -p /run/sshd \
    && sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/*

RUN command -v ssh-keygen \
    && command -v sshd \
    && sshd -V 2>&1 || true
    
RUN python -m pip install --no-cache-dir \
    --upgrade pip setuptools wheel

# LeRobot 0.6.0 对应的 PyTorch/torchvision 版本
RUN python -m pip install --no-cache-dir \
    torch==2.7.1 \
    torchvision==0.22.1 \
    --index-url https://download.pytorch.org/whl/cu126

# 安装 LeRobot、SmolVLA、LIBERO 和 Jupyter
RUN python -m pip install --no-cache-dir \
    "lerobot[smolvla,libero]==0.6.0" \
    jupyterlab \
    ipykernel

# 构建时检查依赖是否完整
RUN python -m pip check

RUN python - <<'PY'
import sys
import torch
import torchvision
import lerobot
import transformers
import mujoco
import libero

from lerobot.policies.smolvla.configuration_smolvla import SmolVLAConfig

print("Python:", sys.version)
print("PyTorch:", torch.__version__)
print("Torchvision:", torchvision.__version__)
print("CUDA runtime:", torch.version.cuda)
print("LeRobot:", lerobot.__file__)
print("Transformers:", transformers.__version__)
print("MuJoCo:", mujoco.__version__)
print("LIBERO:", libero.__file__)
print("SmolVLA import OK")
PY

WORKDIR /workspace

COPY start-container.sh /usr/local/bin/start-container.sh

RUN chmod +x /usr/local/bin/start-container.sh

EXPOSE 22

CMD ["/usr/local/bin/start-container.sh"]
