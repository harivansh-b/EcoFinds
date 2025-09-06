from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import StreamingResponse
from db.connection import get_fs
import uuid
from bson import ObjectId

image_route = APIRouter(prefix="/image")

@image_route.post("/upload")
async def upload_image(file: UploadFile = File(...), fs=Depends(get_fs)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid image file")

    filename = f"{uuid.uuid4()}_{file.filename}"

    grid_in = fs.open_upload_stream(filename, metadata={"content_type": file.content_type})
    contents = await file.read()
    await grid_in.write(contents)
    await grid_in.close()

    return {"message": "Image uploaded successfully", "file_id": str(grid_in._id)}

@image_route.get("/download/{file_id}")
async def download_image(file_id: str, fs=Depends(get_fs)):
    try:
        oid = ObjectId(file_id)
        grid_out = await fs.open_download_stream(oid)
    except Exception:
        raise HTTPException(status_code=404, detail="File not found")

    return StreamingResponse(grid_out, media_type="application/octet-stream")

@image_route.delete("/delete/{file_id}")
async def delete_image(file_id: str, fs=Depends(get_fs)):
    try:
        oid = ObjectId(file_id)
        await fs.delete(oid)
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"File not found or could not be deleted: {str(e)}")
    
    return {"message": f"File {file_id} deleted successfully"}