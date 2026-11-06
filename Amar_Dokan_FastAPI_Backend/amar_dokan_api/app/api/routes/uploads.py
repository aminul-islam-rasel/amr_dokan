import os
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from app.api.deps import get_current_shop, get_current_user
from app.models.shop import Shop
from app.models.user import User

router = APIRouter(tags=["Uploads"])

UPLOAD_DIR = os.path.join(os.getcwd(), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".pdf"}


async def save_uploaded_file(file: UploadFile, prefix: str = "upload") -> str:
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        ext = ".jpg"

    unique_filename = f"{prefix}_{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(UPLOAD_DIR, unique_filename)

    contents = await file.read()
    if len(contents) > 10 * 1024 * 1024:  # 10 MB limit
        raise HTTPException(status_code=400, detail="File size exceeds maximum allowed limit (10MB)")

    with open(filepath, "wb") as f:
        f.write(contents)

    return f"/uploads/{unique_filename}"


@router.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
):
    url = await save_uploaded_file(file, prefix=f"user_{current_user.id[:8]}")
    return {
        "url": url,
        "image_url": url,
        "filename": os.path.basename(url),
        "message": "File uploaded successfully",
    }


@router.post("/shops/{shop_id}/upload")
async def upload_shop_file(
    shop_id: str,
    file: UploadFile = File(...),
    shop: Shop = Depends(get_current_shop),
):
    url = await save_uploaded_file(file, prefix=f"shop_{shop.id[:8]}")
    return {
        "url": url,
        "image_url": url,
        "filename": os.path.basename(url),
        "message": "File uploaded successfully",
    }
