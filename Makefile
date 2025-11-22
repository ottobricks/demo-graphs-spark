.PHONY: install help

UNAME_S := $(shell uname -s)

help:
	@echo "make install  - Install project dependencies"

install-python:
	@command -v uv >/dev/null && echo "uv already installed" || \
	(echo "Installing uv..." && curl -LsSf https://astral.sh/uv/install.sh | sh)
	@uv sync
	@SPARK_HOME=.venv/lib/python3.11/site-packages/pyspark; \
	grep -q "^SPARK_HOME=" .env 2>/dev/null && sed -i.bak "s|^SPARK_HOME=.*|SPARK_HOME=$$SPARK_HOME|" .env || echo "SPARK_HOME=$$SPARK_HOME" >> .env; \
	echo "SPARK_HOME=$$SPARK_HOME set in .env"

install-java:
	@java -version 2>&1 | grep -q "openjdk 17" && echo "OpenJDK 17 already installed" || \
	([ "$(UNAME_S)" = "Linux" ] && (command -v apt-get >/dev/null && sudo apt-get update && sudo apt-get install -y openjdk-17-jdk || \
	 command -v dnf >/dev/null && sudo dnf install -y java-17-openjdk-devel || \
	 command -v yum >/dev/null && sudo yum install -y java-17-openjdk-devel || \
	 command -v pacman >/dev/null && sudo pacman -S --noconfirm jdk17-openjdk) || \
	 [ "$(UNAME_S)" = "Darwin" ] && (brew install openjdk@17 && \
	 sudo ln -sfn $$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true))
	@JAVA_HOME=$$([ "$(UNAME_S)" = "Darwin" ] && /usr/libexec/java_home -v 17 2>/dev/null || dirname $$(dirname $$(readlink -f $$(command -v java) 2>/dev/null || command -v java))); \
	grep -q "^JAVA_HOME=" .env 2>/dev/null && sed -i.bak "s|^JAVA_HOME=.*|JAVA_HOME=$$JAVA_HOME|" .env || echo "JAVA_HOME=$$JAVA_HOME" >> .env; \
	echo "JAVA_HOME=$$JAVA_HOME set in .env"
