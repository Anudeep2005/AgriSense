from pydantic import BaseModel, Field
from typing import List, Optional

class TelemetryReading(BaseModel):
    timestamp: Optional[str] = None
    temperature: float = Field(..., description="Air temperature in °C")
    humidity: float = Field(..., description="Relative humidity in %")
    soil_moisture: float = Field(..., description="Soil moisture in %")
    rain: float = Field(..., description="Raw analog rain sensor reading (e.g. 4095 dry, <2000 rain)")
    is_raining: Optional[int] = Field(None, description="Binary rain indicator (derived automatically if None)")
    ldr_value: float = Field(..., description="Raw LDR photoresistor analog reading (0 to 4095)")
    wind_speed: float = Field(1.5, description="Wind speed in m/s")
    pressure: float = Field(1013.25, description="Atmospheric pressure in hPa")
    cloudiness: float = Field(20.0, description="Cloud cover percentage")

class PredictionRequest(BaseModel):
    history: List[TelemetryReading] = Field(
        ...,
        min_items=1,
        description="Historical sequence of readings (at least 6 readings recommended for 6h lags)"
    )

class HorizonPrediction(BaseModel):
    h6: float = Field(..., alias="6h")
    h10: float = Field(..., alias="10h")
    h24: float = Field(..., alias="24h")
    
    class Config:
        populate_by_name = True

class PredictionResponse(BaseModel):
    temperature: HorizonPrediction
    humidity: HorizonPrediction
    soilMoisture: HorizonPrediction
    modelVersion: str = "xgboost-v1-9models"
