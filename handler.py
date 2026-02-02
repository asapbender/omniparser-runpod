import runpod


def handler(job):
    job_input = job["input"]
    name = job_input.get("name", "World")
    return f"Hello, {name}!"


runpod.serverless.start({"handler": handler})
