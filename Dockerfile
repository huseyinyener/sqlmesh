# Kullanılacak base image
FROM ubuntu:22.04

# Gerekli sistem bağımlılıklarını yükle
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    cron \
    build-essential \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    tzdata \
    git \
    curl \
    unzip \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Zaman dilimi ayarını yapılandır
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# DuckDB CLI aracını yükle (aarch64 için doğru dosya)
RUN curl -L https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-aarch64.zip -o duckdb.zip && \
    unzip duckdb.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/duckdb && \
    rm duckdb.zip

# Python ve pip versiyonlarını kontrol et
RUN python3 --version && pip3 --version

# Gerekli Python paketlerini yükle
RUN pip3 install --no-cache-dir \
    sqlmesh duckdb psycopg2-binary
RUN pip3 install "sqlmesh[web]"

# Çalışma dizinini ayarla
WORKDIR /app

# Cron job için Python scriptlerini kopyala
COPY cron/ /app/cron/

# Cron job dosyasını oluştur ve yükle
RUN echo "*/5 * * * * python3 /app/cron/git_sync_bot.py >> /var/log/git_sync.log 2>&1" > /etc/cron.d/git_sync

# Cron için gerekli izinleri ayarla
RUN chmod 0644 /etc/cron.d/git_sync && crontab /etc/cron.d/git_sync

# Cron'u başlatmak için script oluştur
RUN echo '#!/bin/bash\ncron -f' > /start-cron.sh && chmod +x /start-cron.sh

# Çalışma klasöründeki tüm dosyaları kopyala
COPY . .

# Varsayılan komut (hem cron'u hem de SQLMesh UI'yi başlatır)
CMD ["bash", "-c", "/start-cron.sh & sqlmesh ui --host 0.0.0.0"]
