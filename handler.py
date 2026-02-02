import runpod
import torch
import base64
from PIL import Image
from io import BytesIO
from util.utils import check_ocr_toolbox, get_yolo_model, get_caption_model_processor, get_som_labeled_img

# --- 1. Initialize Models Once ---
print("Loading OmniParser V2.0 models...")
device = "cuda" if torch.cuda.is_available() else "cpu"

# Load YOLO for icon detection
yolo_model = get_yolo_model(model_path='weights/icon_detect/model.pt')
# Load Florence-2 for captioning
caption_model_processor = get_caption_model_processor(
    model_name="florence2",
    model_name_or_path="weights/icon_caption_florence",
    device=device
)

def handler(job):
    # --- 2. Process Input ---
    job_input = job["input"]
    image_b64 = job_input.get("image") # Expects base64 string

    # Decode image
    image_data = base64.b64decode(image_b64)
    img = Image.open(BytesIO(image_data)).convert("RGB")

    # --- 3. Run OmniParser Logic ---
    # box_overlay_ratio and others can be passed from job_input
    dino_labled_img, parsed_content_list = get_som_labeled_img(
        img,
        yolo_model,
        BOX_TRESHOLD=job_input.get("box_threshold", 0.05),
        output_coord_in_ratio=True,
        ocr_bbox_rslt=[], # Assuming vision-only; can add EasyOCR if needed
        draw_bbox_config={'text_scale': 0.8, 'text_thickness': 2},
        caption_model_processor=caption_model_processor
    )

    # --- 4. Return Results ---
    return {
        "parsed_content": parsed_content_list,
        "labeled_image_base64": dino_labled_img # This is usually a base64 string from OmniParser util
    }

runpod.serverless.start({"handler": handler})