# Use a GPU-optimized base image
FROM runpod/base:0.4.0-cuda12.1.0

# Install system dependencies
RUN apt-get update && apt-get install -y git libgl1-mesa-glx libglib2.0-0

# Set working directory
WORKDIR /app

# Clone official OmniParser V2 code
RUN git clone https://github.com/microsoft/OmniParser.git .

# Install dependencies
RUN pip install --no-cache-dir runpod ultralytics timm huggingface_hub
RUN pip install --no-cache-dir -r requirements.txt

# Download V2 Weights (Approx 2GB)
RUN python3 -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')"

# V2 requires the caption folder to be named 'icon_caption_florence'
RUN mv weights/icon_caption weights/icon_caption_florence

# Copy your RunPod handler
COPY handler.py .

# Start the worker
CMD ["python", "-u", "handler.py"]