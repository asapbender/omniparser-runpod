# Use RunPod's stable base image
FROM runpod/base:0.6.2-cuda12.2.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone official OmniParser V2 code
RUN git clone https://github.com/microsoft/OmniParser.git .

# Install PyTorch with CUDA support first
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Install dependencies from OmniParser requirements
RUN pip install --no-cache-dir -r requirements.txt

# Install runpod handler
RUN pip install --no-cache-dir runpod

# Download V2 Weights
RUN pip install --no-cache-dir huggingface_hub && \
    python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')"

# V2 requires the caption folder to be named 'icon_caption_florence'
RUN mv weights/icon_caption weights/icon_caption_florence

# Copy your RunPod handler (overwrites any existing handler.py)
COPY handler.py .

# Start the worker
CMD ["python", "-u", "handler.py"]
