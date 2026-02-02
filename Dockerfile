FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone official OmniParser V2 code
RUN git clone https://github.com/microsoft/OmniParser.git .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir runpod

# Download V2 Weights
RUN python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')"

# Rename caption folder for V2
RUN mv weights/icon_caption weights/icon_caption_florence

# Copy handler
COPY handler.py .

CMD ["python", "-u", "handler.py"]
