.PHONY: install-java install-python help

UNAME_S := $(shell uname -s)

help:
	@echo "make install         - Install Java and Python dependencies"
	@echo "make start-notebook  - Start Marimo Notebook server in the background"
	@echo "make stop-notebook   - Stop Marimo Notebook server"

install: install-python install-java

.PHONY: start-notebook
start-notebook:
	nohup uv run marimo edit ./ --no-token --headless &


.PHONY: stop-notebook
stop-notebook:
	pkill -f marimo


install-java:
	@if java -version 2>&1 | grep -q "openjdk 17"; then \
		echo "OpenJDK 17 already installed"; \
	elif [ "$(UNAME_S)" = "Linux" ]; then \
		command -v apt-get >/dev/null && sudo apt-get update && sudo apt-get install -y openjdk-17-jdk || \
		command -v dnf >/dev/null && sudo dnf install -y java-17-openjdk-devel || \
		command -v yum >/dev/null && sudo yum install -y java-17-openjdk-devel || \
		command -v pacman >/dev/null && sudo pacman -S --noconfirm jdk17-openjdk; \
	elif [ "$(UNAME_S)" = "Darwin" ]; then \
		brew install openjdk@17; \
	fi
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		JAVA_HOME=$$(/usr/libexec/java_home -v 17 2>/dev/null); \
	else \
		JAVA_HOME=$$(dirname $$(dirname $$(readlink -f $$(command -v java)))); \
	fi; \
	grep -q "^JAVA_HOME=" .env 2>/dev/null && sed -i.bak "s|^JAVA_HOME=.*|JAVA_HOME=$$JAVA_HOME|" .env || echo "JAVA_HOME=$$JAVA_HOME" >> .env; \
	echo "JAVA_HOME=$$JAVA_HOME set in .env"

install-python:
	@command -v uv >/dev/null && echo "uv already installed" || \
	(echo "Installing uv..." && curl -LsSf https://astral.sh/uv/install.sh | sh)
	@uv sync
	@SPARK_HOME=.venv/lib/python3.11/site-packages/pyspark; \
	grep -q "^SPARK_HOME=" .env 2>/dev/null && sed -i.bak "s|^SPARK_HOME=.*|SPARK_HOME=$$SPARK_HOME|" .env || echo "SPARK_HOME=$$SPARK_HOME" >> .env; \
	echo "SPARK_HOME=$$SPARK_HOME set in .env"
