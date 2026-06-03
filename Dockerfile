FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

RUN pip install uv

WORKDIR /app

COPY backend/pyproject.toml backend/uv.lock* ./
RUN uv venv .venv && uv sync

RUN uv pip install --upgrade --force-reinstall yt-dlp

COPY backend/src/ ./src/
COPY backend/fonts/ ./fonts/
COPY backend/transitions/ ./transitions/

RUN mkdir -p /tmp/supoclip/uploads /tmp/supoclip/outputs

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "src.main_refactored:app", "--host", "0.0.0.0", "--port", "8000"]
