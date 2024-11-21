FROM debian:bullseye-slim
LABEL MAINTAINER="Birtum <ogc@birtum.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV LANG C.UTF-8

# Install dependencies. (wget python3-venv)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        git \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        python3-cffi \
        python3-dev \
        python3-wheel \
        xz-utils \
        libxslt-dev \
        libzip-dev \
        libldap2-dev \
        libsasl2-dev \
        libpng-dev \
        libjpeg-dev \
        gdebi \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN npm install -g rtlcss \
    npm install -g less \
    npm install -g less-plugin-clean-css

COPY ./requirements.txt /etc/odoo/
RUN pip3 install -r /etc/odoo/requirements.txt

COPY ./requirements_2.txt /etc/odoo/
RUN pip3 install -r /etc/odoo/requirements_2.txt

# Install psql client 
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Add volume to odoo's apps modules
RUN mkdir -p /odoo
VOLUME ["/odoo/", "/var/lib/odoo"]
RUN adduser --system --quiet --shell=/bin/bash --group odoo \
    && chown -R odoo /odoo

# Add entrypoint and odoo's conf file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
RUN chown odoo:odoo /etc/odoo/odoo.conf \
    && chmod 755 /entrypoint.sh

# Add Odoo data directory
RUN mkdir -p /var/lib/odoo
RUN chown -R odoo:odoo /var/lib/odoo

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Add the postsgres await script
COPY ./wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chmod 755 /usr/local/bin/wait-for-psql.py

# Set the user and entrypoint
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "/odoo/odoo/odoo-bin", "--dev=all"]