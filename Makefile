SHELL:= /usr/bin/env bash
NOW:= $(shell date -Is)
PY:= python3.12
vb:= .venv/bin/

.PHONY: env clean really-clean

env: .git/hooks/pre-commit $(vb)wheel
	@source $(vb)activate && \
	pre-commit run --all-files --verbose

.git/hooks/pre-commit: $(vb)pre-commit .pre-commit-config.yaml
	@source $(vb)activate && \
	pre-commit install

$(vb)pre-commit: $(vb)wheel
	@source $(vb)activate && \
	pip install pre-commit

$(vb)wheel: $(vb)activate
	@source $(vb)activate && \
	export PIP_DISABLE_PIP_VERSION_CHECK=true && \
	pip install --upgrade pip setuptools wheel

$(vb)activate:
	$(PY) -m venv .venv

clean:
	@test -d .venv && \
	mv --verbose .venv .venv.$(NOW) && \
	tar --use-compress-program=pzstd --create --file=./.venv.$(NOW).tar.zst .venv.$(NOW) && \
	ls -oh .venv.$(NOW).tar.zst && \
	rm --force --recursive .venv.$(NOW) || \
	echo 'No .venv to clean.'

really-clean:
	@rm --force --recursive --verbose .venv*
