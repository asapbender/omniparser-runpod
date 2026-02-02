FROM runpod/base:0.6.3-cuda11.8.0

# Set python3.11 as the default python
RUN ln -sf $(which python3.11) /usr/local/bin/python && \
    ln -sf $(which python3.11) /usr/local/bin/python3

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /requirements.txt
RUN pip install --upgrade -r /requirements.txt --no-cache-dir

# Clone OmniParser and download weights
RUN git clone https://github.com/microsoft/OmniParser.git /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# Download model weights
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')"
RUN mv weights/icon_caption weights/icon_caption_florence

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
