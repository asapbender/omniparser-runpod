import runpod
import torch
import base64
from PIL import Image
from io import BytesIO
from util.utils import get_yolo_model, get_caption_model_processor, get_som_labeled_img

# --- 1. Initialize Models Once ---
print("Loading OmniParser V2.0 models...")
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

# Load YOLO for icon detection
yolo_model = get_yolo_model(model_path='weights/icon_detect/model.pt')
print("YOLO model loaded.")

# Load Florence-2 for captioning
caption_model_processor = get_caption_model_processor(
    model_name="florence2",
    model_name_or_path="weights/icon_caption_florence",
    device=device
)
print("Caption model loaded.")


def handler(job):
    try:
        # --- 2. Process Input ---
        job_input = job.get("input", {})
        image_b64 = job_input.get("image")

        if not image_b64:
            return {"error": "Missing 'image' field in input. Expected base64 encoded image."}

        # Decode image
        image_data = base64.b64decode(image_b64)
        img = Image.open(BytesIO(image_data)).convert("RGB")

        # --- 3. Run OmniParser Logic ---
        box_threshold = job_input.get("box_threshold", 0.05)
        iou_threshold = job_input.get("iou_threshold", 0.1)
        imgsz = job_input.get("imgsz", 640)

        labeled_img, coords, parsed_content_list = get_som_labeled_img(
            img,
            yolo_model,
            BOX_TRESHOLD=box_threshold,
            iou_threshold=iou_threshold,
            imgsz=imgsz,
            output_coord_in_ratio=True,
            ocr_bbox=None,
            ocr_text=[],
            caption_model_processor=caption_model_processor,
            draw_bbox_config={
                'text_scale': 0.8,
                'text_padding': 5,
                'thickness': 2,
            }
        )

        # --- 4. Return Results ---
        return {
            "parsed_content": parsed_content_list,
            "coordinates": coords,
            "labeled_image_base64": labeled_img
        }

    except Exception as e:
        return {"error": str(e)}


runpod.serverless.start({"handler": handler})