# Use a GPU-optimized base image
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

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

# Install dependencies from OmniParser requirements
RUN pip install --no-cache-dir -r requirements.txt

# Install runpod handler
RUN pip install --no-cache-dir runpod

# Install flash-attn for better Florence-2 performance (optional but recommended)
RUN pip install --no-cache-dir flash-attn --no-build-isolation || true

# Download V2 Weights
RUN huggingface-cli download microsoft/OmniParser-v2.0 --local-dir weights

# V2 requires the caption folder to be named 'icon_caption_florence'
RUN mv weights/icon_caption weights/icon_caption_florence

# Copy your RunPod handler (overwrites any existing handler.py)
COPY handler.py .

# Start the worker
CMD ["python", "-u", "handler.py"]