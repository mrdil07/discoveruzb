"""Pagination yordamchisi — har router'da takrorlamasligimiz uchun."""

from __future__ import annotations

import math
from typing import Annotated, TypeVar

from fastapi import Query
from pydantic import BaseModel
from sqlalchemy import Select, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.common import Page

T = TypeVar("T", bound=BaseModel)


class PageParams(BaseModel):
    page: int = 1
    size: int = 20

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.size


def get_page_params(
    page: Annotated[int, Query(ge=1, le=10000)] = 1,
    size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> PageParams:
    return PageParams(page=page, size=size)


async def paginate(
    db: AsyncSession,
    query: Select,
    *,
    params: PageParams,
    schema: type[T],
) -> Page[T]:
    """`query`'ni count qiladi, sahifa olib, Pydantic'ga konvert qiladi."""
    # Total count — alohida query
    count_query = select(func.count()).select_from(query.subquery())
    total = (await db.execute(count_query)).scalar_one()

    # Items
    items_query = query.offset(params.offset).limit(params.size)
    rows = (await db.execute(items_query)).scalars().all()
    items = [schema.model_validate(row, from_attributes=True) for row in rows]

    total_pages = math.ceil(total / params.size) if total > 0 else 0
    return Page[schema](  # type: ignore[valid-type]
        items=items,
        total=total,
        page=params.page,
        size=params.size,
        total_pages=total_pages,
    )
