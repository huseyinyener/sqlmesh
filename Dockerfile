# Kullanılacak base image
FROM ubuntu:22.04

# Gerekli sistem bağımlılıklarını yükle
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    tzdata \
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

# psycopg2-binary kütüphanesini yükle (alternatif olarak önerilir)
RUN pip3 install --no-cache-dir \
    sqlmesh duckdb psycopg2-binary

RUN pip3 install "sqlmesh[web]"

# Çalışma dizinini ayarla
WORKDIR /app

COPY . .

CMD ["bash", "-c", "sqlmesh ui --host 0.0.0.0"]
