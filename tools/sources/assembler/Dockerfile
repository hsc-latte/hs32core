FROM python:3

ARG wheel
COPY $wheel $wheel

RUN pip install $wheel

ENTRYPOINT ["python", "-m", "hsc_assembler"]
