"""Weather router testlari (OpenWeatherMap chaqirig'i mock qilinadi)."""

from __future__ import annotations

import httpx
import pytest
from httpx import AsyncClient

from app.api.v1 import weather as weather_module
from app.core.config import settings


class _FakeResponse:
    def __init__(self, payload: dict, status_code: int = 200) -> None:
        self._payload = payload
        self.status_code = status_code

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise httpx.HTTPStatusError(
                "error", request=None, response=None  # type: ignore[arg-type]
            )

    def json(self) -> dict:
        return self._payload


class _FakeAsyncClient:
    """`httpx.AsyncClient` o'rnini bosuvchi kontekst-menejer."""

    response: _FakeResponse = _FakeResponse({"main": {"temp": 21.5}})
    calls: int = 0

    def __init__(self, *args, **kwargs) -> None:  # noqa: D107
        pass

    async def __aenter__(self):
        return self

    async def __aexit__(self, *exc) -> None:
        return None

    async def get(self, url, params=None):
        type(self).calls += 1
        return type(self).response


@pytest.fixture(autouse=True)
def _reset(monkeypatch):
    """Har test oldidan kesh va mock holatini tozalash."""
    weather_module._cache.clear()
    _FakeAsyncClient.calls = 0
    _FakeAsyncClient.response = _FakeResponse({"main": {"temp": 21.5}})
    monkeypatch.setattr(weather_module.httpx, "AsyncClient", _FakeAsyncClient)


@pytest.mark.asyncio
async def test_weather_returns_temp(client: AsyncClient, monkeypatch):
    monkeypatch.setattr(settings, "openweather_api_key", "test-key")

    resp = await client.get("/api/v1/weather", params={"lat": 41.31, "lon": 69.24})

    assert resp.status_code == 200
    assert resp.json() == {"temp": 21.5}
    assert _FakeAsyncClient.calls == 1


@pytest.mark.asyncio
async def test_weather_cached_second_call(client: AsyncClient, monkeypatch):
    monkeypatch.setattr(settings, "openweather_api_key", "test-key")

    r1 = await client.get("/api/v1/weather", params={"lat": 41.31, "lon": 69.24})
    r2 = await client.get("/api/v1/weather", params={"lat": 41.31, "lon": 69.24})

    assert r1.status_code == r2.status_code == 200
    assert _FakeAsyncClient.calls == 1  # ikkinchi javob keshdan


@pytest.mark.asyncio
async def test_weather_unconfigured_returns_503(client: AsyncClient, monkeypatch):
    monkeypatch.setattr(settings, "openweather_api_key", "")

    resp = await client.get("/api/v1/weather", params={"lat": 41.31, "lon": 69.24})

    assert resp.status_code == 503


@pytest.mark.asyncio
async def test_weather_upstream_error_returns_502(client: AsyncClient, monkeypatch):
    monkeypatch.setattr(settings, "openweather_api_key", "test-key")
    _FakeAsyncClient.response = _FakeResponse({}, status_code=500)

    resp = await client.get("/api/v1/weather", params={"lat": 41.31, "lon": 69.24})

    assert resp.status_code == 502


@pytest.mark.asyncio
async def test_weather_invalid_coords_422(client: AsyncClient, monkeypatch):
    monkeypatch.setattr(settings, "openweather_api_key", "test-key")

    resp = await client.get("/api/v1/weather", params={"lat": 999, "lon": 69.24})

    assert resp.status_code == 422
