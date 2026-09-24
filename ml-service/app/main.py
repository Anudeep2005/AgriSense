from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from .schemas import PredictionRequest, PredictionResponse
from .predictor import AgriSensePredictor

app = FastAPI(
    title="AgriSense XGBoost Inference Service",
    description="FastAPI service for 9 independent XGBoost environmental regression models",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

predictor = AgriSensePredictor()

@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "agrisense-ml-service",
        "models_ready": predictor.is_ready(),
        "loaded_models": len(predictor.models)
    }

@app.post("/predict", response_model=PredictionResponse)
def predict_telemetry(request: PredictionRequest):
    if not request.history:
        raise HTTPException(status_code=400, detail="History sequence must contain at least 1 reading")
        
    try:
        result = predictor.predict_from_history(request.history)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
