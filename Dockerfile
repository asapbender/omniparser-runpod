FROM runpod/base:0.6.3-cuda11.8.0

COPY requirements.txt /requirements.txt
RUN pip install --upgrade -r /requirements.txt --no-cache-dir

COPY handler.py /handler.py

CMD ["python", "-u", "/handler.py"]
