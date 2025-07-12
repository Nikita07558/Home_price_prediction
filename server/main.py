from fastapi import FastAPI, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import util
import os

# Load model and artifacts
util.load_saved_artifacts()

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files (CSS/JS) from /static/
client_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../client"))
app.mount("/static", StaticFiles(directory=client_path), name="static")

# Serve app.html manually at root
@app.get("/")
def root():
    return FileResponse(os.path.join(client_path, "app.html"))

# API route to get location names
@app.get("/api/get_location_names")
def get_location_names():
    return {"locations": util.get_location_names()}

# API route to predict price
@app.post("/api/predict_home_price")
def predict_home_price(
    total_sqft: float = Form(...),
    location: str = Form(...),
    bhk: int = Form(...),
    bath: int = Form(...)
):
    estimated_price = util.get_estimated_price(location, total_sqft, bhk, bath)
    return {"estimated_price": estimated_price}

# Run only in local dev
if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting FastAPI server...")
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
