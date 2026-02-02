FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone OmniParser
RUN git clone https://github.com/microsoft/OmniParser.git .

# Install PyTorch with CUDA
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir runpod

# Download weights
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')"

# Rename for V2
RUN mv weights/icon_caption weights/icon_caption_florence

COPY handler.py .

CMD ["python", "-u", "handler.py"]
