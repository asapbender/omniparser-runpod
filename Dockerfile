FROM python:3.11-slim

RUN echo "=== Step 1: Installing system dependencies ===" && \
    apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* && \
    echo "=== Step 1: DONE ==="

WORKDIR /app

RUN echo "=== Step 2: Cloning OmniParser ===" && \
    git clone https://github.com/microsoft/OmniParser.git . && \
    echo "=== Step 2: DONE ==="

RUN echo "=== Step 3: Installing PyTorch ===" && \
    pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    echo "=== Step 3: DONE ==="

RUN echo "=== Step 4: Installing requirements ===" && \
    pip install --no-cache-dir -r requirements.txt && \
    echo "=== Step 4: DONE ==="

RUN echo "=== Step 5: Installing runpod ===" && \
    pip install --no-cache-dir runpod && \
    echo "=== Step 5: DONE ==="

RUN echo "=== Step 6: Downloading weights ===" && \
    python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='microsoft/OmniParser-v2.0', local_dir='weights')" && \
    echo "=== Step 6: DONE ==="

RUN echo "=== Step 7: Renaming folder ===" && \
    mv weights/icon_caption weights/icon_caption_florence && \
    echo "=== Step 7: DONE ==="

COPY handler.py .
RUN echo "=== Step 8: Handler copied ==="

CMD ["python", "-u", "handler.py"]
