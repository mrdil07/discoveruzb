"""Weather router — `/api/v1/weather` (OpenWeatherMap server-side proxy).

API key faqat backend'da saqlanadi (`OPENWEATHER_API_KEY`); mobil ilova
to'g'ridan-to'g'ri OpenWeatherMap'ga chiqmaydi. Javob koordinata bo'yicha
`weather_cache_ttl_seconds` davomida in-memory keshlanadi.
"""

from __future__ import annotations

import time
from typing import Annotated

import httpx
from fastapi import APIRouter, HTTPException, Query, status

from app.core.config import settings
from app.core.logging import get_logger
from app.schemas.weather import WeatherRead

logger = get_logger(__name__)

router = APIRouter(prefix="/weather", tags=["weather"])

OPENWEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"

# Kesh kaliti: 2 xona aniqlikdagi (lat, lon) (~1 km) → (monotonic_ts, temp)
_cache: dict[tuple[float, float], tuple[float, float]] = {}


@router.get(
    "",
    response_model=WeatherRead,
    summary="Joy koordinatasi bo'yicha joriy harorat (public)",
)
async def get_weather(
    lat: Annotated[float, Query(ge=-90, le=90)],
    lon: Annotated[float, Query(ge=-180, le=180)],
) -> WeatherRead:
    if not settings.openweather_api_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Ob-havo xizmati sozlanmagan",
        )

    key = (round(lat, 2), round(lon, 2))
    now = time.monotonic()
    cached = _cache.get(key)
    if cached and now - cached[0] < settings.weather_cache_ttl_seconds:
        return WeatherRead(temp=cached[1])

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(
                OPENWEATHER_URL,
                params={
                    "lat": lat,
                    "lon": lon,
                    "appid": settings.openweather_api_key,
                    "units": "metric",
                },
            )
            resp.raise_for_status()
            data = resp.json()
        temp = float(data["main"]["temp"])
    except (httpx.HTTPError, KeyError, TypeError, ValueError) as e:
        logger.warning("OpenWeather so'rovi muvaffaqiyatsiz (%s, %s): %s", lat, lon, e)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Ob-havo xizmati javob bermadi",
        ) from e

    _cache[key] = (now, temp)
    return WeatherRead(temp=temp)
