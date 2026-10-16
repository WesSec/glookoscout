FROM python:3.11-slim

# Force Python to print logs immediately (prevents missing logs in Docker)
ENV PYTHONUNBUFFERED=1

# 1. Install system dependencies required for Google Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    fonts-liberation \
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Add Google's official GPG key and install Google Chrome Stable
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 3. Set up the working directory
WORKDIR /app

# 4. Copy Python requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the application files
COPY sync.py .

# 6. Create a non-root user AND give it permissions to the seleniumbase folder
RUN useradd -m glookouser \
    && chown -R glookouser:glookouser /app \
    && chown -R glookouser:glookouser /usr/local/lib/python3.11/site-packages/seleniumbase

USER glookouser

# 7. Run the sync script
CMD ["python", "sync.py"]