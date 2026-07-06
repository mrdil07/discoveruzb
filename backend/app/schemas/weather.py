"""Weather schemas."""

from __future__ import annotations

from pydantic import BaseModel


class WeatherRead(BaseModel):
    """OpenWeatherMap'dan olingan joriy harorat (°C)."""

    temp: float
